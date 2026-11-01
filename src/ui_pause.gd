extends Control

var menu_scene:PackedScene = preload("res://scenes/stage/menu.scn")


func _on_resume_pressed() -> void:
	get_tree().paused=false
	hide()


func switch_to_menu():
	get_tree().paused=false
	get_tree().change_scene_to_packed(menu_scene)
func _on_menu_pressed() -> void:
	$fg.color.a=0
	$fg.show()
	create_tween().tween_property($fg, "color", Color.BLACK, 0.5)
	get_tree().create_timer(1.5).timeout.connect(switch_to_menu)


func _on_quit_pressed() -> void:
	get_tree().quit()
