extends Node3D
var free_slots = 0b11
var items_visible=true
var active_item = null
var used_item = null
var grab_timeout:Timer
@onready var slot1 = get_node("slot1")
@onready var slot2 = get_node("slot2")

@export var GRAB_ANIM_TIME = 0.2
@export var GRAB_ANIM_EASING:Tween.EaseType
@onready var neutral_position = position
func _ready():
	grab_timeout=Timer.new()
	add_child(grab_timeout)
	grab_timeout.wait_time=0.1
func recalc_free_slots():
	return slot1.get_child_count()|(slot2.get_child_count()<<1)
func grab_item(item:Obj):
	recalc_free_slots()
	if (free_slots)==0 or active_item!=null:
		return
	if (item.get_parent() in [slot1, slot2]): return
	item.grab.emit()
	var target
	print(free_slots)
	if (free_slots)&1:
		target=slot1
		free_slots&=~1
	elif free_slots&2:
		target=slot2
		free_slots&=~2
	item.reparent(target)
	var pos_tween = get_tree().create_tween()
	pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	pos_tween.tween_property(item, "position", Vector3.ZERO, GRAB_ANIM_TIME).set_ease(GRAB_ANIM_EASING)
func drop_item(item:Obj):
	if (item.get_parent() == slot1):
		free_slots|=1
	else:
		free_slots|=2
	if item.original_parent in [slot1, slot2]:
		item.original_parent=$/root/main
	item.reparent(item.original_parent)
	item.ungrab.emit()

func _input(event):
	if (event.is_action_released("hide_grabbed_items")):
		### DISABLED
		return 
		"""items_visible=not items_visible
		var target_position
		if items_visible:
			target_position = neutral_position;
		else:
			target_position = neutral_position-Vector3(0,2,0);
		var tween = get_tree().create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "position", target_position,0.2)"""
func racist(mask=0b10, exclude=[]):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var src = camera.project_ray_origin(mouse_pos)
	var dest = src+camera.project_ray_normal(mouse_pos)*10000.0
	var query = PhysicsRayQueryParameters3D.create(src, dest, mask)
	query.exclude=exclude
	query.collide_with_areas=true
	var result = space_state.intersect_ray(query)
	
	if result:
		return result
func megaracist(mask = 0b10, max_count=1000):
	var results = []
	var exclude = []
	for i in range(max_count):
		var result = racist(mask, exclude)
		if not result:
			break
		results.append(result)
		exclude.append(result["rid"])
	return results
