extends Node3D
@export var edge_scroll_speed=20.0

func _ready():
	if not FileAccess.file_exists("user://game.save"):
		%load.disabled=true
	
	var tween = get_tree().create_tween()
	var edge_noise:FastNoiseLite=%panel.material.get_shader_parameter("burn_texture").noise
	tween.tween_property($WorldEnvironment.environment.glow_map.noise, "offset", Vector3(0,0,10000.0),1000)
	tween.set_parallel(true)
	tween.tween_property(edge_noise, "offset",  Vector3(10000.0,0,0),1000)
func _on_quit_pressed() -> void:
	get_tree().quit()

func play_the_game():
	var game = load("res://scenes/stage/main.tscn")
	get_tree().change_scene_to_packed(game)
func load_save():
	# disabled
	return
	#var game = load("user://save.scn")
	#get_tree().change_scene_to_packed(game)
func _on_play_pressed() -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(%fg, "color", Color.BLACK, 0.2)
	tween.set_parallel(true)
	tween.tween_property($music, "volume_db", -20, 0.2)
	tween.tween_property(%bun, "volume_db", -30, 0.2)
	get_tree().create_timer(0.2).timeout.connect(play_the_game)


func _on_options_pressed() -> void:
	%buttons.hide()
	%options.show()


func _on_back_pressed() -> void:
	%options.hide()
	%buttons.show()


func _on_enable_shadows_toggled(toggled_on: bool) -> void:
	Options.enable_shadows=toggled_on
func _on_enable_bloom_toggled(toggled_on: bool) -> void:
	Options.enable_bloom=toggled_on
func _on_enable_anti_alias_toggled(toggled_on: bool) -> void:
	Options.enable_anti_alias=toggled_on

func _on_volume_master_value_changed(value: float) -> void:
	Options.volume_sfx=value
func _on_volume_music_value_changed(value: float) -> void:
	Options.volume_music=value


func _on_skip_intro_toggled(toggled_on: bool) -> void:
	Options.skip_intro=toggled_on

func _on_skip_tutorial_toggled(toggled_on: bool) -> void:
	Options.skip_tutorial=toggled_on
func _on_salt_physics_toggled(toggled_on: bool) -> void:
	Options.salt_physics=toggled_on

func _on_load_pressed() -> void:
	if not FileAccess.file_exists("user://game.save"):
		return
	var file = FileAccess.open("user://game.save", FileAccess.READ)
	var stats:Statistics = file.get_var(true) as Statistics
	if stats:
		Options.stats=stats
		Options.skip_intro=true
		Options.skip_tutorial=true
		_on_play_pressed()
