extends Control

var FIELD_FMT = {}
func _ready():
	for field in %fields.get_children():
		FIELD_FMT[field.name]=field.text
func _refresh():
	var stats:Statistics=$/root/main.statistics
	for item in %fields.get_children():
		var prop = stats.get(item.name)
		if prop:
			item.text=FIELD_FMT[item.name]%prop
func enable():
	_refresh()
	show()


func _on_close_pressed() -> void:
	hide()
