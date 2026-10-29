class_name UiChest
extends Control
var built = false
var food_panels:Dictionary[Food, FoodPanel] = {}
var category_panels:Dictionary[String, CategoryPanel]
var category_lists:Dictionary[String, HFlowContainer]
var food_resources:Dictionary[StringName, Food]
signal close;
signal recalc;
func _ready():
	var category_counts = {}
	var categories = []
	var category_panel_scene = load("res://category_panel.tscn")
	for food in ResourceLoader.list_directory("foods"):
		var resource:Food = load("foods/"+food)
		print(food, resource)
		if not (resource as Food) :continue
		food_resources[food.split('.')[0]]=resource
		if resource.category not in categories:
			category_counts[resource.category]=0
			categories.append(resource.category)
		category_counts[resource.category]+=1
		var panel = await FoodPanel.from_food(resource, get_tree())
		food_panels[resource]=panel
	for category in categories:
		var panel:CategoryPanel = category_panel_scene.instantiate()
		panel.setup(category, category_counts[category], self)
		$lr/cat_outer/margin/cat.add_child(panel)
		category_panels[category]=panel
		var category_list = HFlowContainer.new()
		category_list.size_flags_horizontal|=Control.SIZE_EXPAND_FILL
		for food in food_panels:
			if food.category==category:
				category_list.add_child(food_panels[food])
		category_list.hide()
		$lr/items_outer/margin/scroll.add_child(category_list)
		category_lists[category]=category_list
	switch_category(categories[0])
func switch_category(category):
	for cat in category_panels:
		category_panels[cat].unset_active()
		category_lists[cat].hide()
	category_panels[category].set_active()
	category_lists[category].show()
func _on_close_pressed() -> void:
	hide()
	
	close.emit()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")) and visible:
		hide()
		close.emit()
