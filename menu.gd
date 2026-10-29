extends Node3D

func _ready():
	var tween = get_tree().create_tween()
	var texture=%panel.get_theme_stylebox("panel").texture as MaterialTexture2D
	if texture:
		texture.update_texture()
	tween.tween_property($WorldEnvironment.environment.glow_map.noise, "offset", Vector3(0,0,10000.0),1000)
func _on_quit_pressed() -> void:
	get_tree().quit()

func play_the_game():
	var game = load("res://main.tscn")
	get_tree().change_scene_to_packed(game)
func _on_play_pressed() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(%fg, "color", Color.BLACK, 0.2)
	tween.set_parallel(true)
	tween.tween_property($music, "volume_db", -20, 0.2)
	tween.tween_property(%bun, "volume_db", -30, 0.2)
	get_tree().create_timer(0.2).timeout.connect(play_the_game)
