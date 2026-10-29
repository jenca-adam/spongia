class_name FoodPanel
extends PanelContainer
@export var food_name="POTATO"
@export var food_desc="Boil 'em, mash 'em, stick 'em in a stew"
@export var thumb:Texture
@export var food:Food

@onready var ui_chest = $/root/main/ui_chest

func _ready():
	$margin/box/thumb.texture=thumb
	$margin/box/name.text=food_name
	$margin/box/desc.text=food_desc
	ui_chest.recalc.connect(_on_ui_chest_recalc)
static func from_food(food:Food, tree:SceneTree)->FoodPanel:
	var panel = load("res://food_item.tscn").instantiate()
	food.thumbnail.bake()
	panel.food_desc = food.desc
	panel.food_name = food.name
	panel.thumb = food.thumbnail
	panel.food=food
	return panel

func _on_ui_chest_recalc():
	print(self, "  recalc!")
	var held_objs = $/root/main.held_objs
	print(held_objs.free_slots)
	if held_objs.free_slots==0:
		$margin/box/buttons/grab.disabled=true
		$margin/box/buttons/grab.tooltip_text = "your hands are full"
	else:
		$margin/box/buttons/grab.disabled=false
		$margin/box/buttons/grab.tooltip_text = ""
func _on_grab_pressed() -> void:
	var held_objs=$/root/main.held_objs
	if not held_objs.free_slots:
		return 
	var scene:Obj = food.scene.instantiate()
	$/root/main/chest.add_child(scene)
	$/root/main.tutorial.set_variable("grabbed_chest_item",1)
	held_objs.grab_item(scene)
	ui_chest.recalc.emit()
