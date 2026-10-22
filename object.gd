class_name Obj
extends Node3D
signal grab
signal ungrab
var grabbed = false
var active = false
var original_parent;
var grab_timeout:Timer
var can_drop=true;
@export var hangs = false
@onready var model:MeshInstance3D = get_node("offset/model")
@onready var held_objs = get_node("%held_objs")
@onready var shape:CollisionShape3D = get_node("offset/hover/CollisionShape3D")
var query_shape := BoxShape3D.new()
func _ready():
	grab_timeout=Timer.new()
	add_child(grab_timeout)
	grab_timeout.wait_time=0.1
	original_parent=get_parent()
	query_shape.size =model.get_aabb().size
func _on_hover_mouse_entered() -> void:
	model.material_overlay.set_shader_parameter("outline_width",1.0)


func _on_hover_mouse_exited() -> void:
	model.material_overlay.set_shader_parameter("outline_width",0.0)


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
	print (space.intersect_shape(query, 1))
	return space.intersect_shape(query, 1).size() > 0
func _physics_process(delta):
	global_rotation=Vector3(0, global_rotation.y, 0)
	if active:
		var pos = held_objs.racist(hangs)
		if pos:
			var aabb:AABB = model.get_aabb()
			global_position=pos+Vector3(0,aabb.size.y/2,0);
			if would_collide():
				model.material_overlay.next_pass.albedo_color=Color(1,0,0,0.2)
				can_drop=false
			else:
				model.material_overlay.next_pass.albedo_color=Color(0,1,0,0.2)
				can_drop=true
			print(can_drop)
		else:
			can_drop=false
			model.material_overlay.next_pass.albedo_color=Color(1,0,0,0.2)
			position=Vector3.ZERO
func _on_hover_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event.is_action_released("interact")):
		print(active, grabbed, grab_timeout.is_stopped(), grab_timeout.time_left)
		if not grabbed and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1):
			held_objs.grab_item(self)
		elif not active and grabbed and held_objs.active_item==null and (grab_timeout.is_stopped() or grab_timeout.time_left<0.1):
			held_objs.active_item=self
			active=true
func _input(event):
	if event.is_action_released("drop_obj") and active and can_drop:
		active=false
		grabbed=false
		held_objs.active_item=null
		print("starting?")
		grab_timeout.start(0.1)
		held_objs.drop_item(self)
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)
	if event.is_action_released("cancel_obj_drop") and active:
		active=false
		held_objs.active_item=null
		position=Vector3.ZERO
		model.material_overlay.next_pass.albedo_color=Color(0,1,0,0)
