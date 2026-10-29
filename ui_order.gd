class_name UiOrder
extends Control

func _ready():
	visibility_changed.connect(recalculate_corners)
	recalculate_corners()
func setup(bestellung:Bestellung):
	%image.texture = bestellung.customer.image
	%customer_type.text = bestellung.customer.name
	%customer_name.text = bestellung.selected_customer_name
	%order_text.text = bestellung.selected_order_line
func recalculate_corners():
	var height_coeff = size.y/size.x
	%panel.material.set_shader_parameter("height", height_coeff)

func _on_ok_pressed() -> void:
	if name=="ui_order":
		## not inherited
		$/root/main.tutorial.set_variable(&"seen_order",1)
	hide()
