extends ObjContainer

var cooking = false
func _on_turkey_area_entered(area: Area3D) -> void:
	if $turkey.get_overlapping_areas():
		print("COOKING")
		cooking=true


func _on_turkey_area_exited(area: Area3D) -> void:
	if not $turkey.get_overlapping_areas():
		print("L")
		cooking=false
func _process(delta):
	if cooking:
		for body in bodies:
			var b = body as Cuttable
			if not b:
				continue
			b.cook_time+=delta
