class_name Customer
extends Resource
@export var name:StringName
@export var image:Texture2D
@export var orders:JSONLoadable
@export var names:JSONLoadable
@export var comments:Comments
@export var taste_profile:TasteProfile

func score(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	return taste_profile.score(other_taste_profile)

func get_comment_scores(other_taste_profile:TasteProfile, items:Array[Cuttable]):
	return taste_profile.get_comment_scores(other_taste_profile)
