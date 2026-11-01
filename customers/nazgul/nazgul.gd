class_name Nazgul
extends Customer

func score(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	if items:
		return 0.0
	return 1.0

func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	if items:
		return [[1.0, "bad1"], [1.0, "bad2"], [1.0, "hand_warn"]]
	return [[1.0, "good1"], [1.0, "good2"], [1.0, "hand_ok"]]
