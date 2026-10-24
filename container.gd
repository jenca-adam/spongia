class_name ObjContainer
extends Obj
var bodies:Array[Obj]
var neutral_positions = {}
var full = false
var last_entered_tick = -1
var last_exited_tick = -1
var moving:bool=false
@onready var top_plane = $offset/top_plane
@onready var top_plane_coll = $offset/top_plane/CollisionShape3D
@onready var contents = $offset/contents
@onready var contents_coll = $offset/contents/CollisionShape3D
@onready var internal_collider = $offset/internal_collider
@onready var internal_collider_coll = $offset/internal_collider/CollisionShape3D
var _last_global_pos:Vector3
var _still_frames=0
func _ready():
	super._ready()
	top_plane_coll.shape = _generate_top_plane_shape()
	top_plane.position = _generate_top_plane_position()
	_set_contents_collider()
	internal_collider_coll.shape = shape.shape
	internal_collider_coll.global_transform=shape.global_transform
	cancel.connect(_on_cancelled)
	_last_global_pos = global_position
func _generate_top_plane_shape()->BoxShape3D:
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size*0.5
	box_shape.size.y = 0.2
	return box_shape
func _generate_top_plane_position()->Vector3:
	var position = aabb.position+aabb.size*0.5+offset
	position.y = aabb.end.y
	return position
func _set_contents_collider()->void:
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
	if b in bodies:
		return
	b.in_container = true
	b.collision_mask &= ~(1 << 11)
	b.unfreeze()
	bodies.append(b)
	global_exclude.append(b.hover.get_rid())
	if b.release.is_connected(_on_body_entered):
		b.release.disconnect(_on_body_entered)
	var cb := _on_body_frozen.bind(b)
	if not b.frozen.is_connected(cb):
		b.frozen.connect(cb)
	_reparent_body.call_deferred(b, $bodies, true)
func _on_contents_body_entered(body: Node3D) -> void:
	var b = body as Obj
	if not b or body.find_parent("held_objs"):
		return
	if b in bodies:
		return
	b.collision_mask &= ~(1 << 11) # harmless if re-entering
	if not b.release.is_connected(_on_body_entered):
		b.release.connect(_on_body_entered)

	#b.sleeping_state_changed.connect(_on_body_sleeping_state_changed.bind(body))

func _on_contents_body_exited(body: Node3D) -> void:
	var b = body as Obj
	if not b:
		return
	if b.release.is_connected(_on_body_entered):
		b.release.disconnect(_on_body_entered)
	if b not in bodies:
		return
	# Spurious exit caused by the container moving: body is carried along
	# as our child, so it hasn't really left. Re-checked when we stop.
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
	if (b.grabbed):
		for body in bodies:
			body.unfreeze() #  mayhem?
		return
	_reparent_body.call_deferred(b, $/root/main, false)

func _revalidate_bodies() -> void:
	for b in bodies.duplicate():
		if is_instance_valid(b) and not contents.overlaps_body(b):
			_confirm_exit(b)
func _confirm_exit(b: Obj) -> void:
	# wait for physics to settle, then make sure it's really outside
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_instance_valid(b) or b not in bodies:
		return
	if contents.overlaps_body(b):
		return
	_release_body(b)

func _on_cancelled(foo):
	for body in bodies:
		body.position = neutral_positions.get(body, body.position)
