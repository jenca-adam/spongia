class_name Tutorial

var root_node:Main
var ui:UiTutorial
var enabled=true
var state=0

var state_to_check:Dictionary[int, Callable] = {
	0: func(): return true,
	1: _check1,
	2: _check2,
	3: _check3,
	4: _check4,
	5: _check5,
	6: _check6,
	7: _check7,
	8: _check8,
	9: _check9,
	10: _check10,
	11: _check11,
	12: _check12,
	13: _check13
}
var _variables:Dictionary[StringName, Variant] = {}
func skip():
	enabled=false

func setup(root:Main):
	root_node=root
	ui=root_node.get_node("ui_tutorial")
	ui.setup(self)
func set_variable(name:StringName, val:Variant=1):
	if not enabled:return
	if ui.showing:return
	_variables[name]=val
	tutorial_check()
func advance():
	if not enabled:return
	_variables.clear() # so that the player can't break ordering
	state+=1
	ui.show_state(state)
func _check_default():
	return false
func tutorial_check():
	if not enabled:return
	var f:Callable = state_to_check.get(state, _check_default)
	if f:
		var result = f.call()
		if result:
			advance()
func _check1():
	for camera in range(root_node.cams.size()):
		if not _variables.get(&"cam_%d"%camera):
			return false
	return true
func _check2():
	return bool(_variables.get(&"cam_admin",0))
func _check3():
	return bool(_variables.get(&"seen_order",0))
func _check4():
	return bool(_variables.get(&"cam_1",0))
func _check5():
	return bool(_variables.get(&"seen_chest",0) and _variables.get(&"grabbed_chest_item",0))
func _check6():
	return bool(_variables.get(&"item_on_board",0) and _variables.get(&"knife_grabbed",0))
func _check7():
	return bool(_variables.get(&"item_cut",0))
func _check8():
	return bool(_variables.get(&"pot_grabbed",0) and _variables.get(&"cam_0",0))
func _check9():
	return bool(_variables.get(&"item_in_pot",0))
func _check10():
	return bool(_variables.get(&"cooking",0))
func _check11():
	return bool(_variables.get(&"pot_grabbed",0))
func _check12():
	return bool(_variables.get(&"container_placed",0))
func _check13():
	return bool(_variables.get(&"meal_submitted",0))
