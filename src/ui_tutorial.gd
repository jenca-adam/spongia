class_name UiTutorial
extends Control

var tutorial:Tutorial
var showing=0
func _on_ok_pressed() -> void:
	var node:=get_node_or_null("%d"%showing)
	if node: node.hide()
	showing=0
	hide()

func _on_skip_pressed() -> void:
	hide()
	showing=false
	if tutorial:
		tutorial.skip()

func setup(tut:Tutorial):
	tutorial=tut
	if not tutorial.enabled:
		hide()
	if tutorial.state!=0:
		show_state(tutorial.state)
func show_state(state:int):
	_on_ok_pressed()
	var node:=get_node_or_null("%d"%state)
	if node:
		showing=state
		node.show()
		show()
