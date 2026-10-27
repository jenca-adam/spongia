class_name TasteVector
extends Resource

@export_range(0,1,0.01)
var sweet:float;
@export_range(0,1,0.01)
var sour:float;
@export_range(0,1,0.01)
var salty:float;
@export_range(0,1,0.01)
var meaty:float;
@export_range(0,1,0.01)
var healthy:float;
@export_range(0,1,0.01)
var filling:float;
@export_range(0,1,0.01)
var spicy:float
const PROPERTIES = ["sweet", "sour", "salty", "meaty", "healthy", "filling","spicy"]

func weighted_add(other:TasteVector, weight:float)->void:
	for prop in PROPERTIES:
		set(prop, get(prop)+other.get(prop)*weight)
func divide(den:float)->void:
	for prop in PROPERTIES:
		set(prop,get(prop)/den)
