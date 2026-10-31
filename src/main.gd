class_name Main
extends Node3D
const cams = ["prep_table","chest", "fire", "shelf"];
@export var customers:Array[Customer]
var cur_cam = 0;
@export
var CAM_SWITCH_TIME = 1.0;
@export
var CAM_SWITCH_EASE = Tween.EASE_OUT
var switching = 0
var current_order:Bestellung
var served=1
var statistics:Statistics
@export var START_CAM:Camera3D
@onready var held_objs = $cams/trans/held_objs
@onready var admin_cam= $cams/admin_table
@export var tutorial_enable:bool
var tutorial:Tutorial
func _zizi(new_cam:Camera3D):
	switching = 0
	new_cam.make_current()
	
func switch_cam(prev_node:Camera3D, cam_node:Camera3D, rot_offset=Vector3.ZERO):
	switching = 1
	
	var trans: Camera3D = get_node("cams/trans")
	trans.position = prev_node.position
	trans.fov = prev_node.fov
	trans.rotation = prev_node.rotation
	trans.make_current()
	var tween = get_tree().create_tween()
	tween.tween_property(trans, "position", cam_node.position, CAM_SWITCH_TIME).set_ease(CAM_SWITCH_EASE)
	tween.set_parallel()
	tween.tween_property(trans, "fov", cam_node.fov, CAM_SWITCH_TIME).set_ease(CAM_SWITCH_EASE)
	tween.tween_property(trans, "rotation", cam_node.rotation, CAM_SWITCH_TIME).set_ease(CAM_SWITCH_EASE)
	var timer = get_tree().create_timer(CAM_SWITCH_TIME)
	await timer.timeout;
	_zizi(cam_node)
func _input(event: InputEvent):
	if $ui_tutorial.showing:
		return
	if $ui_chest.visible or switching  or held_objs.used_item!=null or held_objs.active_item!=null:
		return
	var next_cam = cur_cam
	var off=0
	
	if event.is_action_pressed("admin_cam_enable") and not admin_cam.current:
		var cur_cam_node: Camera3D = get_node("cams/%s"%cams[cur_cam]);
		if abs(admin_cam.rotation.y - cur_cam_node.rotation.y)>PI:
			if (admin_cam.rotation.y-cur_cam_node.rotation.y<0):
				off=1
			else:
				off=-1
		admin_cam.rotation.y+=2*PI*off
		switch_cam(cur_cam_node, admin_cam)
		tutorial.set_variable(&"cam_admin",1)
		return
	if event.is_action_pressed("admin_cam_disable") and admin_cam.current:
		var new_cam_node:  Camera3D = get_node("cams/%s"%cams[cur_cam])
		tutorial.set_variable(&"cam_%d"%(cams.find(cams[cur_cam])), 1)
		switch_cam(admin_cam,new_cam_node)
	if admin_cam.current:
		return
	if (event.is_action_pressed("next_cam") and not switching and held_objs.used_item==null and held_objs.active_item==null):
		next_cam = (cur_cam+1)%len(cams)
	
	elif event.is_action_pressed("prev_cam") and not switching and held_objs.used_item==null and held_objs.active_item==null:
		next_cam = (cur_cam-1)%len(cams)
	if (next_cam!=cur_cam):
		
		#if abs(next_cam.rotation.y-cur_cam.rotation.y)
		var cam_node: Camera3D = get_node("cams/%s"%cams[next_cam]);
		var cur_cam_node: Camera3D = get_node("cams/%s"%cams[cur_cam]);
		
		if abs(cam_node.rotation.y - cur_cam_node.rotation.y)>PI:
			if (cam_node.rotation.y-cur_cam_node.rotation.y<0):
				off=1
			else:
				off=-1
		cam_node.rotation.y+=2*PI*off
		switch_cam(cur_cam_node, cam_node)
		
		cur_cam = next_cam
		tutorial.set_variable(&"cam_%d"%(cams.find(cams[cur_cam])), 1)
	if event.is_action_released("DEBUG"):
		SaveGame.save_scene(self, "user://game.save")
func save_game():
	SaveGame.save_scene(self, "user://game.save")
func next_customer():
	var customer = customers.slice(0,served).pick_random()
	current_order = Bestellung.from_customer(customer)
	print(customer.orders.items)
	$ui_order.setup(current_order)
func _ready():
	switch_cam(START_CAM, START_CAM)
	cur_cam = cams.find(START_CAM.name)
	next_customer()
	tutorial = Tutorial.new()
	tutorial.setup(self)
	tutorial.enabled=tutorial_enable and not Options.skip_tutorial
	tutorial.set_variable(&"cam_%d"%cur_cam, 1)
	tutorial.tutorial_check()
	if not tutorial.enabled:
		$ui_tutorial.hide()
	else:
		$ui_tutorial.show()
	var sfx_index = AudioServer.get_bus_index(&"SFX")
	var music_index = AudioServer.get_bus_index(&"Music")
	AudioServer.set_bus_volume_linear(sfx_index, Options.volume_sfx)
	AudioServer.set_bus_volume_linear(music_index, Options.volume_music)
	if Options.skip_intro:
		$intro.hide()
		$intro.play=false
	if not Options.enable_shadows:
		get_viewport().positional_shadow_atlas_size=0
		$WorldEnvironment/DirectionalLight3D.shadow_enabled=false
	if not Options.enable_bloom:
		$WorldEnvironment.environment.glow_enabled=false
	if not Options.enable_anti_alias:
		get_viewport().screen_space_aa=Viewport.SCREEN_SPACE_AA_DISABLED
	if not Options.salt_physics:
		$salt_physics.queue_free()
		
	if Options.stats==null:
		statistics = Statistics.new()
	else:
		statistics=Options.stats
	
	statistics.setup($ui_chest.food_resources.values(), customers, $ui_chest.food_resources)
func _on_ui_result_close() -> void:
	$admin.clear()
	served+=1
	next_customer()
