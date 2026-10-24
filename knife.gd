extends Tool

var cutting: Array[Cuttable] = []
var cut_axis = 0

# Returns an array of [Cuttable, Vector3 position], one entry per unique Cuttable
func get_cutting() -> Array:
	var results = $/root/main.held_objs.megaracist(0b10000 << cut_axis)
	var hits: Array = []
	for result in results:
		var cuttable = result["collider"].get_parent().get_parent() as Cuttable
		
		if cuttable == null or not cuttable.freeze:
			continue
		
		hits.append([cuttable, result["position"]])
	return hits

func _end_all_cutting() -> void:
	for c in cutting:
		if is_instance_valid(c):
			c.cut_end.emit()
	cutting.clear()
func _get_axis_offset_basis() -> Basis:
	match cut_axis:
		0: return Basis.from_euler(Vector3(0, -PI/2, 0))
		1: return Basis.from_euler(Vector3(0, PI, 0))
		_: return Basis.from_euler(Vector3(0, 0, -PI/2))
func _on_use() -> void:
	var hits = get_cutting()
	var aabb2 = model.get_aabb() * model.transform # do not precalculate to account for anim

	if hits.size() > 0:
		var new_cutting: Array[Cuttable] = []
		for hit in hits:
			new_cutting.append(hit[0])
		for c in cutting:
			if is_instance_valid(c) and not (c in new_cutting):
				c.cut_end.emit()
		for c in new_cutting:
			if not (c in cutting):
				c.cut_start.emit(cut_axis)
		cutting = new_cutting
		for hit in hits:
			hit[0].show_cut(hits[0][1])
		var collider: Cuttable = hits[0][0]
		var collider_position: Vector3 = hits[0][1]
		global_basis = _get_axis_offset_basis()
		
		var local_shift: Vector3
		if cut_axis == 2:
			local_shift = Vector3(-aabb2.position.x, 0, 0)
		else:
			local_shift = Vector3(0, -aabb2.position.y, 0)
		global_position = collider_position + global_basis * local_shift - offset
	elif not anim.is_playing():
		position = Vector3.ZERO
		global_rotation = neutral_rotation
		_end_all_cutting()

func _on_unuse() -> void:
	if cutting.size() > 0:
		_end_all_cutting()
		global_rotation = neutral_rotation

func _set_axis(axis: int) -> void:
	if cut_axis != axis:
		for c in cutting:
			if is_instance_valid(c):
				c.cut_start.emit(axis)
	cut_axis = axis

func _input(event):
	super._input(event)
	if event.is_action_released("set_cut_axis_z") and using:
		_set_axis(0)
	if event.is_action_released("set_cut_axis_x") and using:
		_set_axis(1)
	if event.is_action_released("set_cut_axis_y") and using:
		_set_axis(2)
	if event.is_action_released("knife_cut") and using:
		var hits = get_cutting()
		var did_cut = false
		for hit in hits:
			var collider: Cuttable = hit[0]
			if is_instance_valid(collider) and collider.cut(hits[0][1]):
				did_cut = true
		if did_cut:
			anim.play("cut")
			$audio.play()
