class_name ObjContainer
extends Tool
var bodies:Array[Obj]
var neutral_positions = {}
var full = false
var last_entered_tick = -1
var last_exited_tick = -1
var moving:bool=false
var can_tip=false
@export var can_cut_contents=false
@export var VERTICAL_MOVEMENT_SPEED=1
@export_range(-180, 180, 0.1, "radians_as_degrees") var rotation_angle: float = -PI
@export var rotation_axis = Vector3(0,0,1)
@onready var top_plane = $offset/top_plane
@onready var top_plane_coll = $offset/top_plane/CollisionShape3D
@onready var contents = $offset/contents
@onready var contents_coll = $offset/contents/CollisionShape3D
@onready var internal_collider = $offset/internal_collider
@onready var definitely_contents = $offset/definitely_contents
@onready var internal_collider_coll = $offset/internal_collider/CollisionShape3D
var _last_global_pos:Vector3
var _still_frames=0
var deltay = 0
var miny
var maxy
var tipping
var done_check
func _ready():
	super._ready()
	rotatable=true
	if top_plane_coll.shape == null:
		top_plane_coll.shape = _generate_top_plane_shape()
	top_plane.position = _generate_top_plane_position()
	_set_contents_collider()
	internal_collider_coll.shape = shape.shape
	internal_collider_coll.global_transform=shape.global_transform
	cancel.connect(_on_cancelled)
	_last_global_pos = global_position
	use.connect(_on_use)
	unuse.connect(_on_unuse)
	done_check = get_node_or_null("done_check")



func _generate_top_plane_shape()->BoxShape3D:
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size*0.9
	box_shape.size.y = 0.2
	return box_shape
func _generate_top_plane_position()->Vector3:
	var position = aabb.position+aabb.size*0.5+offset
	position.y = aabb.end.y
	return position
func _set_contents_collider()->void:
	if contents_coll.shape != null: return
	var box_shape = BoxShape3D.new()
	var aabb2:AABB=aabb
	aabb2.end.y+=1
	box_shape.size = aabb2.size
	var pos = aabb2.position+aabb2.size*0.5
	contents_coll.shape=box_shape
	contents_coll.position=pos

func _physics_process(delta):
	super._physics_process(delta)
	if active:
		internal_collider.collision_mask = 0
	else:
		internal_collider.collision_mask |= (1 << 10)
	
		for body in definitely_contents.get_overlapping_bodies():
			if not active and body is Obj and not body.active and not body.grabbed and body.containable and body not in bodies:
				_on_body_entered(body as Obj)
	var was_moving := moving
	if global_position.is_equal_approx(_last_global_pos):
		_still_frames += 1
		if _still_frames >= 3:
			moving = false
	else:
		_still_frames = 0
		moving = true
	_last_global_pos = global_position

	if was_moving and not moving:
		_revalidate_bodies()
	if using:
		global_position.y+=delta*deltay*VERTICAL_MOVEMENT_SPEED
		if miny and maxy:
			global_position.y=clampf(global_position.y, miny, maxy)
	if done_check:
		var d = done_check as Area3D
		for area in d.get_overlapping_areas():
			if area.get_parent().name=="admin":
				$/root/main.tutorial.set_variable(&"container_placed",1)
func is_full():
	var colliders = contents.get_overlapping_bodies()
	for collider in colliders:
		var coll = collider as Obj
		if not coll:
			continue
		if coll.freeze and coll.in_container:
			return true
	return false
func _on_body_sleeping_state_changed(body:Obj):
	if body.sleeping and is_full():
		#top_plane.collision_layer=0
		full=true
func _on_body_frozen(b:Obj):
	neutral_positions[b]=b.position

func _on_body_entered(b: Obj) -> void:
	
	if b == null  or b in bodies or Time.get_ticks_msec()-b.tipped_on<1000:
		return
	if not b.containable or b.in_container and b.container!=self:
		return
	print("ENTER", b, self)
	b.in_container = true
	b.collision_mask &= ~(1 << 11)
	b.container=self
	b.unfreeze()
	bodies.append(b)
	global_exclude.append(b.hover.get_rid())
	if b.release.is_connected(_on_body_entered):
		b.release.disconnect(_on_body_entered)
	var cb := _on_body_frozen.bind(b)
	if not b.frozen.is_connected(cb):
		b.frozen.connect(cb)
	_reparent_body.call_deferred(b, $bodies, true)
	if can_cut_contents:
		$/root/main.tutorial.set_variable(&"item_on_board",1)
	if name=="pot":
		$/root/main.tutorial.set_variable(&"item_in_pot",1)
func _on_contents_body_entered(body: Node3D) -> void:
	var b = body as Obj
	
	if not b or body.find_parent("held_objs"):
		return
	if b in bodies:
		return
	b.collision_mask &= ~(1 << 11)
	b.collision_layer &= ~(1<<11)
	# cut results have $bodies as parent
	
	if b.find_parent("bodies") == $bodies :
		_on_body_entered(b)
		return
	if not b.release.is_connected(_on_body_entered):
		b.release.connect(_on_body_entered)

	#b.sleeping_state_changed.connect(_on_body_sleeping_state_changed.bind(body))

func _on_contents_body_exited(body: Node3D) -> void:
	var b = body as Obj
	if not b:
		return
	#b.can_sleep=true
	if b.release.is_connected(_on_body_entered):
		b.release.disconnect(_on_body_entered)
	if b not in bodies:
		return
	if moving and b.get_parent() == $bodies:
		return
	_confirm_exit(b)
func _reparent_body(b: Obj, new_parent: Node, expect_inside: bool) -> void:
	if not is_instance_valid(b) or not is_instance_valid(new_parent):
		return
	if (b in bodies) != expect_inside:
		return 
	if b.get_parent() == new_parent:
		return
	var xf := b.global_transform
	var lin := b.linear_velocity
	var ang := b.angular_velocity
	b.reparent(new_parent, true)
	b.global_transform = xf
	b.linear_velocity = lin
	b.angular_velocity = ang

func _release_body(b: Obj) -> void:
	bodies.erase(b)
	global_exclude.erase(b.hover.get_rid())
	neutral_positions.erase(b)
	var cb := _on_body_frozen.bind(b)
	if b.frozen.is_connected(cb):
		b.frozen.disconnect(cb)
	b.in_container = false
	b.collision_mask |= (1 << 11)
	b.collision_layer|=(1 << 11)
	b.container=null
	if (b.grabbed):
		for body in bodies:
			if is_instance_valid(body):
				body.unfreeze() #  mayhem?
		return
	_reparent_body.call_deferred(b, $/root/main, false)

func _revalidate_bodies() -> void:
	for b in bodies.duplicate():
		if is_instance_valid(b) and not contents.overlaps_body(b):
			_confirm_exit(b)
func _confirm_exit(b: Obj) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_instance_valid(b) or b not in bodies:
		return
	if contents.overlaps_body(b):
		return
	_release_body(b)

func _on_cancelled(...foo):
	for body in bodies:
		if not is_instance_valid(body):
			continue
		body.position = neutral_positions.get(body, body.position)
func _on_activated(...foo):
	pass


## TIPPING

func _on_use():
	var held_objs = $/root/main.held_objs
	var surface = held_objs.racist(0b10|(1<<9), [top_plane.get_rid()])
	if not surface:
		can_tip=false
		return
	can_tip=true
	var pos = surface["position"]
	var gpos = pos#+rotation_axis*aabb.size.x
	var steepest = min(abs(rotation_angle), PI/2)
	var big = aabb.size.dot(rotation_axis)*sin(steepest)
	miny = pos.y+big/2
	maxy = pos.y+big*3
	gpos.y=global_position.y
	global_position=gpos
func _reenable_collision():
	internal_collider.set_collision_layer_value(11, true)
	set_collision_layer_value(12, true)
func _tip_reset():
	tipping=false
	rot_lock=false
	internal_collider.set_collision_layer_value(11, false)
	set_collision_layer_value(12, false)
	get_tree().create_timer(0.1).timeout.connect(_reenable_collision)
	_unuse()
func _tip_reset_after_timeout():
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_tip_reset)
func _tip():
	freed_clear()
	for body in bodies.duplicate():
		if not is_instance_valid(body):
			continue
		_release_body(body)
		body.enable_freeze_on_sleep=false
		body.unfreeze()
		body.tipped_on=Time.get_ticks_msec()
		#body.frozen.connect(func():breakpoint)
	var tween = get_tree().create_tween()
	tipping=true
	rot_lock=true
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel(true)
	tween.tween_property(self, "rotation", rotation+(rotation_angle)*rotation_axis, 0.5)
	tween.finished.connect(_tip_reset_after_timeout)
func _input(event:InputEvent):
	super._input(event)
	if not using or tipping or not can_tip:
		return
	if event.is_action_pressed("tip_confirm"):
		_tip()
		return
	if (event.is_echo()): return
	var dy = -1 if event.is_action("tip_move_down") else (1 if event.is_action("tip_move_up") else 0)
	if not dy: return
	if event.is_released():
		dy*=-1
	deltay+=dy

func _on_unuse():
	_on_cancelled(67)

func freed_clear():
	var new_bodies:Array[Obj] = []
	for body in bodies:
		if is_instance_valid(body):
			new_bodies.append(body)
	bodies=new_bodies
