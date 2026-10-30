class_name CategoryPanel
extends PanelContainer
var category_name;
var parent:UiChest
func setup(cat:String, count:int, p):
	category_name=cat
	$margin/category_label.text="%s (%d)"%[cat, count]
	parent=p

func _on_margin_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		parent.switch_category(category_name)
func set_active():
	$margin/category_label.add_theme_color_override("font_color", Color.YELLOW)
func unset_active():
	$margin/category_label.add_theme_color_override("font_color", Color.WHITE)
