class_name Samwise
extends Customer
@export var potato_threshold=0.5
@export var potato_bonus=0.1
func _get_potato_volume(items: Array[Cuttable]):
	var total_potato_volume = 0
	for item in items:
		if item.type=="potato":
			total_potato_volume+=item.volume
	return total_potato_volume

func score(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	var old_score = super.score(other_taste_profile, items)
	var total_potato_volume = _get_potato_volume(items)
	if total_potato_volume > potato_threshold:
		old_score+=potato_bonus
	return min(old_score, 1.0)

func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable])->Array:
	var old_comment_scores=super.get_comment_scores(other_taste_profile, items)
	var total_potato_volume = _get_potato_volume(items)
	if total_potato_volume > potato_threshold:
		old_comment_scores.append([999.0, "potato"])
	return old_comment_scores
