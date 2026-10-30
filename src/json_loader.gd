@tool
class_name JSONLoadable
extends Resource

@export_file("*.json") var json_path: String:
	set(value):
		json_path = value
		load_json()

@export var items: Array[String] = []
@export_tool_button("Reload", "Reload") var reload_action=load_json
func load_json() -> void:
	#if not Engine.is_editor_hint():		return

	if json_path.is_empty():
		return

	if not FileAccess.file_exists(json_path):
		push_warning("not found: " + json_path)
		return

	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return

	var json := JSON.new()
	var error := json.parse(file.get_as_text())

	if error != OK:
		push_warning("parsing failed: " + json.get_error_message())
		return

	if not json.data is Array:
		push_warning("not an array")
		return

	var parsed_items: Array[String] = []

	for item in json.data:
		if item is String:
			parsed_items.append(item)

	items = parsed_items

func pick_random():
	return items.pick_random()
