@tool
class_name Comments
extends Resource
@export var not_cooked:JSONLoadable
@export var not_healthy:JSONLoadable
@export var not_meaty:JSONLoadable
@export var not_much:JSONLoadable
@export var not_salty:JSONLoadable
@export var not_sour:JSONLoadable
@export var not_sweet:JSONLoadable
@export var not_textured:JSONLoadable
@export var not_spicy:JSONLoadable
@export var too_cooked:JSONLoadable
@export var too_healthy:JSONLoadable
@export var too_meaty:JSONLoadable
@export var too_much:JSONLoadable
@export var too_salty:JSONLoadable
@export var too_sour:JSONLoadable
@export var too_sweet:JSONLoadable
@export var too_textured:JSONLoadable
@export var too_spicy:JSONLoadable
@export_dir var dir_path: String:
	set(value):
		dir_path = value
		load_dir()
const CATEGORIES=["not_cooked", "not_healthy", "not_meaty", "not_much", "not_salty", "not_sour", "not_sweet", "not_textured", "not_spicy", "too_cooked", "too_healthy", "too_meaty", "too_much", "too_salty", "too_sour", "too_sweet", "too_textured", "too_spicy"]
@export_tool_button("Reload", "Reload") 
var reload_action=load_dir
func load_dir():
	var files = ResourceLoader.list_directory(dir_path)
	var category_to_file = {}
	for file in files:
		category_to_file[file.split('.')[0]]=dir_path.path_join(file)
	print(category_to_file)
	for category in CATEGORIES:
		if category in category_to_file:
			var loadable = JSONLoadable.new()
			loadable.json_path=category_to_file[category]
			set(category, loadable)
			
