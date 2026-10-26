class_name Obj
extends Hoverable
signal grab
signal ungrab
var grabbed = false
var active = false
var original_parent;
var old_cl;
var old_cm;
var rot_lock=false;
var can_drop=false;
var drop_disabled = false;

var in_container=false;
var global_exclude=[]
var enable_freeze_on_sleep=true
signal unfrozen
signal frozen
@export var hangs = false
@export var thumb:Texture

@onready var shape:CollisionShape3D = get_node("offset/hover/CollisionShape3D")
@onready var offset:Vector3 = get_node("offset").position
@onready var droppable_mat = load("res://droppable.tres")
@onready var neutral_rotation = global_rotation
@onready var collision_shape:CollisionShape3D= $CollisionShape3D
@onready var phys_mat = load("res://rough_ph.tres")
@export var rotatable = true
@export var containable = false
var aabb
var rotating=false
var tipped_on=-10000
var query_shape := BoxShape3D.new()
var rotating_origin:Vector2
var rotating_base:Vector3
var grab_timeout:Timer
var container:ObjContainer
signal release(what:Obj)
signal cancel(what:Obj)
func unfreeze():
	
	unfrozen.emit()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze=false
	if not in_container:
		collision_mask |= 1<<11
func freeze_():
	frozen.emit()
	freeze=true
	collision_mask&= ~(1<<11)
	neutral_rotation=global_rotation

func _ready():
	super._ready()
	collision_layer=0
	collision_mask = 0
	collision_layer |= 1<<11
	if containable:
		collision_layer |= 1<<10
		collision_mask |= 1<<10
		collision_mask |= 1<<12
		collision_layer |= 1<<13
	input_ray_pickable=false
	#$thumb/thumbcam.hide()
	
	original_parent=get_parent()
	query_shape.size =model.get_aabb().size
	model.material_overlay = droppable_mat.duplicate_deep()
	shape.shape = model.mesh.create_trimesh_shape()
	shape.transform = model.transform
	collision_shape.shape = model.mesh.create_convex_shape(false, false)
	collision_shape.global_transform = model.global_transform
	
	collision_shape.debug_color=Color(0,1,0,0.5)
	grab.connect(_on_grab)
	ungrab.connect(_on_ungrab)
	
	aabb=model.transform*model.get_aabb()
	physics_material_override = phys_mat
	sleeping_state_changed.connect(_on_sleeping_state_changed)
	max_contacts_reported=10
	contact_monitor=true
	if containable== null:
		containable=false
	freeze_()
func neutralize_rotation():
	pass

func _on_grab() -> void:
	grabbed = true
	model.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func would_collide() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape =collision_shape.shape

	query.transform = model.global_transform
	query.collision_mask = 1
	query.exclude = [shape.get_parent().get_rid(), get_rid()]+global_exclude
	var space := get_world_3d().direct_space_state
	var result=space.intersect_shape(query, 1)
	if result:
		print(result[0].collider.get_parent().get_parent())
	return result.size()>0
func _physics_process(delta):
	if grab_timeout == null:
		grab_timeout = $/root/main.held_objs.grab_timeout
	if rotating:
		var mouse_position = get_viewport().get_mouse_position()
		global_rotation.y=rotating_base.y+rotating_origin.angle_to_point(mouse_position)
	if freeze and not rot_lock:
		global_rotation=Vector3(neutral_rotation.x, global_rotation.y, neutral_rotation.z)
	if active:
		var result = $/root/main.held_objs.racist(0b10|(0b100 if hangs else 0)|(1<<9 if containable else 0))
		if result:
			var pos = result["position"]
			global_position=pos-Vector3(0,aabb.position.y,0)-offset;
			if would_collide():
				model.material_overlay.next_pass.albedo_color=Color(1,0,0,0.4)
				can_drop=false
			else:
				model.material_overlay.next_pass.albedo_color=Color(0,1,0,0.4)
				can_drop=true
			#print(can_drop)
		else:
			can_drop=false
			model.material_overlay.next_pass.albedo_color=Color(1,0,0,0.4)
			position=Vector3.ZERO
func _on_hover_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if (event.is_action_released("interact") and not drop_disabled):
		if in_container:
			var bodies = find_parent("bodies")
			if bodies and bodies.get_parent() is ObjContainer:
				if bodies.get_parent().grab_timeout.time_left>=0.1 and not bodies.get_parent().grab_timeout.is_stopped():
					return
		if not grabbed and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1) and $/root/main.held_objs.active_item==null and $/root/main.held_objs.used_item==null:
			self.freeze_()
			$/root/main.held_objs.grab_item(self)
		elif not active and grabbed and $/root/main.held_objs.active_item==null and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1):
			$/root/main.held_objs.active_item=self
			active=true
			set_collision_layer_value(11, false)
			set_collision_mask_value(11, false)
			print("activating", self)
func _input(event):
	if event.is_action_released("rotation_begin") and hovered and rotatable and not rotating:
		rotating=true
		drop_disabled=true
		rotating_origin = get_viewport().get_visible_rect().size/2.0
		rotating_base = global_rotation
	if event.is_action_released("rotation_end") and rotating:
		rotating=false
		drop_disabled=false
		set_hover_outline()
	if drop_disabled:
		return
	if event.is_action_released("drop_obj") and active and can_drop:
		print("deactivating (dropping)", self)
		set_collision_layer_value(11, containable)
		set_collision_mask_value(11, containable)
		active=false
		grabbed=false
		$/root/main.held_objs.active_item=null
		#print("starting?")
		grab_timeout.start(0.1)
		$/root/main.held_objs.drop_item(self)
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)
		release.emit(self)
	if event.is_action_released("cancel_obj_drop") and active:
		active=false
		$/root/main.held_objs.active_item=null
		var tween = get_tree().create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "position", Vector3.ZERO, 0.2)
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)
		cancel.emit(self)
		

func _on_ungrab() -> void:
	model.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _on_sleeping_state_changed() -> void:
	if (sleeping and not freeze and enable_freeze_on_sleep):
		freeze_()
