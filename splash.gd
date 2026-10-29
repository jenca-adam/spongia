extends Control
@export var step = 0.2
@export var offset = 0.0
@export var glow_time = 2.0
var scene
func show_node_and_play_sound(node:Control):
	node.show()
	$type.play()
func switch_to_game():
	get_tree().change_scene_to_packed(scene)
func tween_glow():
	var tween = get_tree().create_tween()
	tween.tween_property($WorldEnvironment.environment, "glow_mix", 1, glow_time)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(1)
	tween.tween_property(%bg,"color", Color.BLACK, glow_time)
	scene= load("res://main.tscn")
	get_tree().create_timer(glow_time).timeout.connect(switch_to_game)
func _ready():
	var time = offset
	for letter in %text.get_children():
		get_tree().create_timer(time).timeout.connect(show_node_and_play_sound.bind(letter))
		time+=step
	get_tree().create_timer(time).timeout.connect(tween_glow)
