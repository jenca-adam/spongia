extends Node3D
@onready
var anim_player:AnimationPlayer = get_node("AnimationPlayer")
@onready
var creak:AudioStreamPlayer3D = get_node("creak")
func _on_click_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_released("interact"):
		if not anim_player.is_playing():
			creak.play();
		anim_player.play("open")
		
