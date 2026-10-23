extends Tool
var cutting:Cuttable=null
var cut_axis = 0
func get_cutting():
	var result = $/root/main.held_objs.racist(0b10000<<cut_axis)
	if not result:
		return [null, null]
	return [result["collider"].get_parent().get_parent(), result.position]
func _on_use() -> void:
	var result=get_cutting()
	var collider = result[0]
	var collider_position =result[1]
	var aabb2 = model.get_aabb()*model.transform # do not precalculate to account for anim
	
	if collider:
	
		if (collider!=cutting):
			if (cutting!=null):
				cutting.cut_end.emit()
			cutting=collider
			cutting.cut_start.emit(cut_axis)
		collider.show_cut(collider_position)
		global_position = collider_position-Vector3(0,aabb2.position.y,0)-offset;
		if (cut_axis==0):
			global_rotation = collider.global_rotation+Vector3(0,-PI/2, 0);
		else:
			global_rotation = collider.global_rotation+Vector3(0, PI, 0);
	else:
		position=Vector3.ZERO
		global_rotation=neutral_rotation
		if (cutting!=null):
				cutting.cut_end.emit()
				cutting=null
func _on_unuse() ->void:
	if (cutting!=null):
		cutting.cut_end.emit()
		cutting=null
		global_rotation=neutral_rotation
func _input(event):
	super._input(event)
	if (event.is_action_released("set_cut_axis_z") and using):
		if cut_axis==1 and cutting!=null:
			cutting.cut_start.emit(0)
		cut_axis=0
	if (event.is_action_released("set_cut_axis_x") and using):
		if cut_axis==0 and cutting!=null:
			cutting.cut_start.emit(1)
		cut_axis=1
	if (event.is_action_released("knife_cut") and using):
		var result = get_cutting()
		var collider:Cuttable =result[0]
		var collider_position = result[1]
		if (collider):
			anim.play("cut")
			$audio.play()
			collider.cut(collider_position)
			collider = null
