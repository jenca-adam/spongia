extends Node3D
@onready
var anim_player:AnimationPlayer = get_node("AnimationPlayer")
@onready
var creak:AudioStreamPlayer3D = get_node("creak")
var opened=false
func _ready():
	$/root/main/ui_chest.close.connect(_on_ui_chest_close)
func _on_click_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_released("interact") and not opened:
		opened=true
		if not anim_player.is_playing():
			creak.play();
		anim_player.play("open")
		$/root/main/ui_chest.show()
		$/root/main/ui_chest.recalc.emit()
func _on_ui_chest_close():
	if opened:
		opened=false
		creak.play()
		anim_player.play("close")
