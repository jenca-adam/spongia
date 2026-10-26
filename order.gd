extends Hoverable
func _ready():
	super._ready()
func _on_hover_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event.is_action_pressed("interact")):
		$/root/main/ui_order.show()
