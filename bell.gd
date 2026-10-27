extends Hoverable

func _on_hover_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event.is_action_released("interact") and not $anim.is_playing()):
		var tp = ($/root/main/admin.get_taste_profile())
		$anim.play("ring")
		$ring.play()
