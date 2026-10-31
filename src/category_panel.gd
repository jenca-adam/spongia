class_name CategoryPanel
extends PanelContainer

### fugly
var category_name;
var parent:UiChest
var active=false
func setup(cat:String, count:int, p):
	category_name=cat
	$margin/category_label.text="%s (%d)"%[cat, count]
	parent=p
	$margin/category_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
func _on_margin_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		parent.switch_category(category_name)
func set_active():
	active=true
	$margin/category_label.add_theme_color_override("font_color", Color.YELLOW)
func unset_active():
	active=false
	$margin/category_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)


func _on_margin_mouse_entered() -> void:
	if not active:
		$margin/category_label.add_theme_color_override("font_color",Color.WHITE)


func _on_margin_mouse_exited() -> void:
	if not active:
		$margin/category_label.add_theme_color_override("font_color",Color.LIGHT_GRAY)
