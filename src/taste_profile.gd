class_name TasteProfile
extends Resource

@export var taste_vector: TasteVector
@export_range(0, 30, 1) var cook_time: float
@export_range(0, 10, 0.1) var amount: float
@export_range(0, 1, 0.01) var texture: float # ratio of biggest ingredient to total volume
const COOK_TIME_WEIGHT := 4.0
const AMOUNT_WEIGHT := 4.0
func setup():
	taste_vector = TasteVector.new()

func punish(error:float, curve=0.5 ) -> float:
	return pow(clampf(error, 0.0, 1.0), curve)

func get_comment_scores(result: TasteProfile) -> Array:
	var comment_scores = taste_vector.get_comment_scores(result.taste_vector)
	comment_scores.append([(result.cook_time - cook_time) / 30 * COOK_TIME_WEIGHT, "too_cooked"])
	comment_scores.append([(cook_time - result.cook_time) / 30 * COOK_TIME_WEIGHT, "not_cooked"])
	comment_scores.append([(result.amount/amount-1) / 10 * AMOUNT_WEIGHT, "too_much"])
	comment_scores.append([(amount/result.amount-1) / 10 * AMOUNT_WEIGHT, "not_much"])
	comment_scores.append([(result.texture - texture), "too_textured"])
	comment_scores.append([(texture - result.texture), "not_textured"])
	comment_scores.sort()
	return comment_scores

func score(other: TasteProfile) -> float:
	var result := 0.0
	if (other.amount<amount/10):
		return 0
	result += punish(abs(other.cook_time - cook_time) / 30.0) * COOK_TIME_WEIGHT
	result += punish(abs(other.amount - amount) / 10.0, 0.3) * AMOUNT_WEIGHT
	result += abs(other.texture - texture)
	result += taste_vector.score(other.taste_vector)
	var max_penalty := COOK_TIME_WEIGHT + AMOUNT_WEIGHT + 1.0 + taste_vector.PROPERTIES.size()
	return 1.0 - (result / max_penalty)
