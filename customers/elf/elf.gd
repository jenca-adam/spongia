class_name Elf
extends Customer
@export var lembas_threshold=0.1
@export var lembas_bonus=0.15
func _get_lembas_volume(items: Array[Cuttable]):
	var total_lembas_volume = 0
	for item in items:
		if item.type=="lembas":
			total_lembas_volume+=item.volume
	return total_lembas_volume

func score(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	var old_score = super.score(other_taste_profile, items)
	var total_lembas_volume = _get_lembas_volume(items)
	if total_lembas_volume > lembas_threshold:
		old_score+=lembas_bonus
	return min(old_score, 1.0)

func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable])->Array:
	var old_comment_scores=super.get_comment_scores(other_taste_profile, items)
	var total_lembas_volume = _get_lembas_volume(items)
	if total_lembas_volume > lembas_threshold:
		old_comment_scores.append([999.0, "lembas"])
	return old_comment_scores
