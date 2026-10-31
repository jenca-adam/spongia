class_name SaveGame
extends Object
static func save_scene(root:Main , path: String) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_var(root.statistics, true)
	file.close()
static func load_scene(root:Main, path:String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	root.statistics = file.get_var(true)
