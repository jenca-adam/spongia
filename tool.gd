class_name Tool
extends Obj
signal use
signal unuse
@onready var anim:AnimationPlayer =get_node_or_null("anim")
var using:=false


func _ready():
	super._ready()
	rotatable=false
	collision_layer=0
	if anim:
		grab.connect(_play_anim_grab)
		ungrab.connect(_play_anim_ungrab)
func _play_anim_grab():
	anim.play("pick_up")
func _play_anim_ungrab():
	anim.play("unpick_up")
func _physics_process(delta):
	super._physics_process(delta)
	if using:
		use.emit()
func _unuse():
	$/root/main.held_objs.used_item=null
	using=false
	unuse.emit()
	drop_disabled=false
	position=Vector3.ZERO
	model.material_overlay.next_pass.albedo_color=Color(1,1,1,0.0)
	model.material_overlay.set_shader_parameter("outline_color", Color(1,1,1))
	model.material_overlay.set_shader_parameter("outline_width", 0.0)

func _input(event):
	super._input(event)
	if (event.is_action_released("tool_use")) and not using and grabbed and hovered and not active and $/root/main.held_objs.used_item==null:
		using=true
		drop_disabled=true
		$/root/main.held_objs.used_item=self
		model.material_overlay.set_shader_parameter("outline_color", Color(1,1,0))
		model.material_overlay.set_shader_parameter("outline_width", 1.0)
		model.material_overlay.next_pass.albedo_color=Color(1,1,0,0.2)
	elif (event.is_action_released("cancel_tool_use") and using and grabbed):
		_unuse()
