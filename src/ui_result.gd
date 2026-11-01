extends UiOrder
signal close
var dictionary_stylebox:StyleBoxFlat
func _ready():
	super._ready()
	dictionary_stylebox=%dictionary.get_theme_stylebox("panel")
	%dictionary.hide()
func setup_result(bestellung:Bestellung, result_taste_profile:TasteProfile, result_items:Array[Cuttable]):
	super.setup(bestellung)
	if bestellung.customer.name=="Elf":
		%dictionary.show()
	else:
		%dictionary.hide()
	var target = bestellung.customer
	var score = target.score(result_taste_profile, result_items)
	var comment_scores = target.get_comment_scores(result_taste_profile, result_items)
	var top_3 = comment_scores.slice(comment_scores.size()-3)
	top_3.reverse()
	var comment_bb := ""
	for comment in top_3:
		#var comment_score = comment[0]
		var comment_name = comment[1]
		
		var comment_text = bestellung.customer.comments.get_cat_list(comment_name).items.pick_random()
		if "__KILL_HAND" in comment_text and $/root/main.held_objs.killed_hand:
			continue
		comment_bb+=comment_text+'\n'
	if "__KILL_HAND" in comment_bb:
		$/root/main.held_objs.kill_hand()
	%comments.text="[ul]%s[/ul]"%comment_bb
	%rating.text="%.2f"%(score*100.0)+"%"
	$/root/main.statistics.log_result(bestellung, result_items, score*100.0)
func _on_ok_pressed():
	super._on_ok_pressed()
	$/root/main.tutorial.set_variable(&"meal_submitted", 1)
	$/root/main.save_game()
	close.emit()


func _on_dictionary_mouse_entered() -> void:
	dictionary_stylebox.border_color=Color.WHITE



func _on_dictionary_mouse_exited() -> void:
	dictionary_stylebox.border_color=Color.TRANSPARENT


func _on_dictionary_gui_input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact")):
		$/root/main/ui_dictionary.show()
