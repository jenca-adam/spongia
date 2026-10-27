class_name TasteProfile
extends Resource
@export
var taste_vector:TasteVector
@export_range(0,120,1)
var cook_time:float;
@export_range(0,10,0.1)
var amount:float;
@export_range(0,1,0.01)
var texture:float; #ratio of biggest ingredient to total volume
func setup():
	taste_vector = TasteVector.new()
