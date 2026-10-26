class_name Food
extends Resource

@export var name:String
@export var desc:String
@export var category:String
@export var scene:PackedScene
@export var thumbnail:Texture
@export var taste_vector:TasteVector
func _init():
	name=""
	desc=""
