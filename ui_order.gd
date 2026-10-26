extends Control


func setup(bestellung:Bestellung):
	%image.texture = bestellung.customer.image
	%customer_type.text = bestellung.customer.name
	%customer_name.text = bestellung.selected_customer_name
	%order_text.text = bestellung.selected_order_line


func _on_ok_pressed() -> void:
	hide()
