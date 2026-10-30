class_name Shaker
extends Tool
var salted_container:ObjContainer
@export var y_offset=0.5;
@export var strength=0.1;
var shaking=false
func _on_use():
	var held_objs=$/root/main.held_objs
	var result = held_objs.racist(1<<31)
	if result:
		print(result)
		var cont = result["collider"].get_parent().get_parent()
		if not (cont is ObjContainer):
			self.position=Vector3.ZERO
			salted_container=null
			global_rotation=neutral_rotation
			stop_shaking()
			return
		salted_container=cont
		global_position = result["position"]
		global_position.y+=y_offset;
		global_rotation.z=PI
	else:
		self.position=Vector3.ZERO
		salted_container=null
		global_rotation=neutral_rotation
		stop_shaking()
	if shaking and salted_container:
		salted_container.add_salt(strength*get_physics_process_delta_time())
func start_shaking():
	shaking=true
	$particles.emitting=true
	$shake.play()
	$shanim.play("shake")
func stop_shaking():
	# hör auf zu beben!
	shaking=false
	$particles.emitting=false
	$shake.stop()
	$shanim.play("RESET")
	
func _input(event):
	super._input(event)
	if event.is_action_pressed("interact") and using and salted_container:
		start_shaking()
	if event.is_action_released("interact") and using and salted_container:
		stop_shaking()


func _on_unuse() -> void:
	stop_shaking()
