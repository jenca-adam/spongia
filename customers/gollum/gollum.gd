class_name Gollum
extends Customer

func score(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	for item in items:
		if item.type!="fish" or item.cook_time>0:
			return 0.0
	if not items:
		return 0.0
	return 1.0
	
func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	for item in items:
		if item.type!="fish" or item.cook_time>0:
			return [[1,"gollum_bad"],[1,"gollum_bad"],[1,"gollum_bad"]]
	if not items:
			return [[1,"gollum_bad"],[1,"gollum_bad"],[1,"gollum_bad"]]
	return [[1,"gollum_good"],[1,"gollum_good"],[1,"gollum_good"]]
