extends Control
@export var logo_time = 1.0
@export var logo_fade = 1.0
@export var step = 0.2
@export var offset = 0.0
@export var glow_time = 2.0
@export var linger=0.4
@export var logo_zoom_time=2.0
@export var logo_zoom_amount=1.4
@export var fade_color=Color.hex(0xc9ffa300)
@export var text_fade=1.5
var scene
func show_node_and_play_sound(node:Control, end:bool):
	node.show()
	if end:
		$bell.play()
	else:
		$type.play()

func switch_to_game():
	get_tree().change_scene_to_packed(scene)
func tween_fade():
	var target_color=fade_color
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(%text, "modulate", target_color, text_fade).set_ease(Tween.EASE_OUT)
	tween.tween_property($hum, "volume_db", linear_to_db(0.01), text_fade).set_ease(Tween.EASE_OUT)
func tween_glow():
	
	var tween = get_tree().create_tween()
	tween.tween_property($WorldEnvironment.environment, "glow_mix", 1, glow_time)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(1)
	tween.tween_property(%bg,"color", Color.BLACK, glow_time)
	scene= load("res://scenes/stage/menu.scn")
	get_tree().create_timer(glow_time).timeout.connect(tween_fade)
	get_tree().create_timer(glow_time+linger+text_fade).timeout.connect(switch_to_game)

func typewrite():
	var time = offset+logo_time+logo_fade
	var index=0
	var letters = %text.get_children()
	for letter in letters:
		index+=1
		get_tree().create_timer(time).timeout.connect(show_node_and_play_sound.bind(letter, index==letters.size()))
		time+=step
	get_tree().create_timer(time).timeout.connect(tween_glow)
func zoom_logo():
	$whoosh.play()
	var tween = get_tree().create_tween()
	var zoom = logo_zoom_amount*%logo.offset_transform_scale.x
	tween.tween_property(%logo, "offset_transform_scale", Vector2(zoom, zoom), logo_zoom_time).set_ease(Tween.EASE_OUT)
func fade_logo():
	var tween = get_tree().create_tween()
	var target_color = fade_color
	tween.tween_property(%logo, "modulate", target_color, logo_fade)

func _ready():
	get_tree().create_timer(logo_time).timeout.connect(fade_logo)
	get_tree().create_timer(logo_time+logo_fade).timeout.connect(%logo.hide)
	typewrite()
	zoom_logo()
	
