extends ObjContainer

var cooking = false
func _ready():
	super._ready()
	grab.connect(_pot_grabbed)
func _on_turkey_area_entered(area: Area3D) -> void:
	if $turkey.get_overlapping_areas():
		print("COOKING")
		cooking=true
		$/root/main.tutorial.set_variable(&"cooking")
	

func _on_turkey_area_exited(area: Area3D) -> void:
	if not $turkey.get_overlapping_areas():
		print("L")
		$/root/main.tutorial.set_variable(&"uncooking")
		cooking=false
func _process(delta):
	if cooking:
		for body in bodies:
			var b = body as Cuttable
			if not b:
				continue
			b.cook_time+=delta
		$/root/main.statistics.log_cook_frame(delta)
func _pot_grabbed():
	$/root/main.tutorial.set_variable(&"pot_grabbed",1)
