class_name Obj
extends Node3D
signal grab
signal ungrab
var grabbed = false
var active = false
var original_parent;
var grab_timeout:Timer
var can_drop=false;
var drop_disabled = false;
var hovered=false
@export var hangs = false
@onready var model:MeshInstance3D = get_node("offset/model")
@onready var hover:CollisionObject3D = get_node("offset/hover")
@onready var shape:CollisionShape3D = get_node("offset/hover/CollisionShape3D")
@onready var offset:Vector3 = get_node("offset").position
@onready var droppable_mat = load("res://droppable.tres")
@onready var neutral_rotation = global_rotation
var aabb
var query_shape := BoxShape3D.new()

func _ready():
	grab_timeout=Timer.new()
	add_child(grab_timeout)
	grab_timeout.wait_time=0.1
	original_parent=get_parent()
	query_shape.size =model.get_aabb().size
	model.material_overlay = droppable_mat.duplicate_deep()
	shape.shape = model.mesh.create_trimesh_shape()
	shape.transform = model.transform
	grab.connect(_on_grab)
	ungrab.connect(_on_ungrab)
	hover.input_event.connect(_on_hover_input_event)
	hover.mouse_entered.connect(_on_hover_mouse_entered)
	hover.mouse_exited.connect(_on_hover_mouse_exited)
	aabb=model.transform*model.get_aabb()
	print(aabb.size.y, ' ' ,aabb.position.y)
func _on_hover_mouse_entered() -> void:
	if drop_disabled:
		return
	model.material_overlay.set_shader_parameter("outline_width",1.0)
	hovered = true

func _on_hover_mouse_exited() -> void:
	if drop_disabled:
		return
	model.material_overlay.set_shader_parameter("outline_width",0.0)
	hovered=false

func _on_grab() -> void:
	grabbed = true
	model.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func would_collide() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = query_shape
	# center the box on the AABB, not on the node origin
	var xform: Transform3D = model.global_transform
	xform.origin = model.global_transform * model.get_aabb().get_center()
	query.transform = xform
	query.collision_mask = 1
	query.exclude = [shape.get_parent().get_rid()]
	var space := get_world_3d().direct_space_state
	
	return space.intersect_shape(query, 1).size() > 0
func _physics_process(delta):
	global_rotation=Vector3(neutral_rotation.x, global_rotation.y, neutral_rotation.z)
	if active:
		var result = $/root/main.held_objs.racist(0b10|(0b100 if hangs else 0))
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
		
		if not grabbed and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1) and $/root/main.held_objs.active_item==null and $/root/main.held_objs.used_item==null:
			$/root/main.held_objs.grab_item(self)
		elif not active and grabbed and $/root/main.held_objs.active_item==null and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1):
			$/root/main.held_objs.active_item=self
			active=true
			print("activating", self)
func _input(event):
	if drop_disabled:
		return
	if event.is_action_released("drop_obj") and active and can_drop:
		print("deactivating (dropping)", self)
		active=false
		grabbed=false
		$/root/main.held_objs.active_item=null
		#print("starting?")
		grab_timeout.start(0.1)
		$/root/main.held_objs.drop_item(self)
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)
	if event.is_action_released("cancel_obj_drop") and active:
		active=false
		$/root/main.held_objs.active_item=null
		position=Vector3.ZERO
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)


func _on_ungrab() -> void:
	model.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
