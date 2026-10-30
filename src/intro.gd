extends Control
@export var fade_in_time=0.5
@export var fade_out_time=0.5
@export var end_fade_time=1.5
@export var hold_time=3.0
@export var play=true
func fade_out():
	get_tree().create_tween().tween_property($bg, "self_modulate",Color.TRANSPARENT, end_fade_time)
	
func fade_in_node(node:Control):
	
	node.self_modulate.a=0
	node.show()
	get_tree().create_tween().tween_property(node, "self_modulate", Color.WHITE, fade_in_time)
func fade_out_node(node:Control):
	var target = Color.WHITE
	target.a=0
	get_tree().create_tween().tween_property(node, "self_modulate", target, fade_in_time)
func _ready():
	if not play or Options.skip_intro:
		hide()
		return
	var time=0.0
	for line in %lines.get_children():
		get_tree().create_timer(time).timeout.connect(fade_in_node.bind(line))
		time+=fade_in_time+hold_time
		get_tree().create_timer(time).timeout.connect(fade_out_node.bind(line))
		time+=fade_out_time
	get_tree().create_timer(time).timeout.connect(fade_out)
	get_tree().create_timer(time+end_fade_time).timeout.connect(hide)
