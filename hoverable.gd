class_name Hoverable extends RigidBody3D
var model
var hover
var hovered=false
var disable_hover_set=false
var disable_hover_outline=false
func set_hover_outline():
	model.material_overlay.set_shader_parameter("outline_width",1.0 if (hovered and not disable_hover_outline) else 0.0)

func _ready():
	if hover == null:
		hover = get_node("offset/hover")
	if model ==null:
		model=get_node("offset/model")
	hover.input_event.connect(_on_hover_input_event)
	hover.mouse_entered.connect(_on_hover_mouse_entered)

	hover.mouse_exited.connect(_on_hover_mouse_exited)
func _on_hover_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	pass
func _on_hover_mouse_entered():
	if disable_hover_set:
		return
	hovered=true
	set_hover_outline()
func _on_hover_mouse_exited():
	if disable_hover_set:
		return
	hovered=false
	set_hover_outline()
