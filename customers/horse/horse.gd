class_name Horse
extends Customer
@export var min_carrot_amount=0.5

func score(other_taste_profile:TasteProfile, other_items:Array[Cuttable]):
	var total_volume=0.0;
	var carrot_volume=0.0;
	for item in other_items:
		if item.type in ["carrot", "apple"]:
			carrot_volume+=item.volume
		total_volume+=item.volume
	if total_volume==0.0:
		return 0
	var carrot_amount_score = min(1.0, carrot_volume/min_carrot_amount)
	var carrot_proportion_score = carrot_volume/total_volume
	return carrot_amount_score*carrot_proportion_score
func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	return [[1.0, "neigh"], [1.0, "neigh"], [1.0, "neigh"]] 
