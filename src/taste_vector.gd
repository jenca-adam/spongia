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
func get_comment_scores(result:TasteVector)->Array:
	var scores = []
	for prop in PROPERTIES:
		scores.append([result.get(prop)-get(prop), &"too_%s"%prop])
		scores.append([get(prop)-result.get(prop), &"not_%s"%prop])
	return scores
func score(other:TasteVector)->float:
	var result = 0.0
	for prop in PROPERTIES:
		result += abs(get(prop)-other.get(prop))
	return result
