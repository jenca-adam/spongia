extends Node3D
var free_slots = 0b11
var items_visible=true
var active_item = null
@onready var slot1 = get_node("slot1")
@onready var slot2 = get_node("slot2")

@export var GRAB_ANIM_TIME = 0.2
@export var GRAB_ANIM_EASING:Tween.EaseType
@onready var neutral_position = position
func grab_item(item:Obj):
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
	pos_tween.tween_property(item, "position", Vector3.ZERO, GRAB_ANIM_TIME).set_ease(GRAB_ANIM_EASING)
	item.global_rotation=Vector3.ZERO
func drop_item(item:Obj):
	if (item.get_parent() == slot1):
		free_slots|=1
	else:
		free_slots|=2
	item.reparent(item.original_parent)
	item.ungrab.emit()
func _input(event):
	if (event.is_action_released("hide_grabbed_items")):
		items_visible=not items_visible
		var target_position
		if items_visible:
			target_position = neutral_position;
		else:
			target_position = neutral_position-Vector3(0,2,0);
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", target_position,0.2)
func racist(hangs):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var src = camera.project_ray_origin(mouse_pos)
	var dest = src+camera.project_ray_normal(mouse_pos)*1000.0
	var query = PhysicsRayQueryParameters3D.create(src, dest, 0b10|(0b100 if hangs else 0))
	var result = space_state.intersect_ray(query)
	print(result)
	if result:
		return result["position"]
