extends UiOrder
signal close
func setup_result(bestellung:Bestellung, result_taste_profile:TasteProfile):
	super.setup(bestellung)
	var target_taste_profile = bestellung.customer.taste_profile
	var score = target_taste_profile.score(result_taste_profile)
	var comment_scores = target_taste_profile.get_comment_scores(result_taste_profile)
	var top_3 = comment_scores.slice(comment_scores.size()-3)
	top_3.reverse()
	var comment_bb = ""
	for comment in top_3:
		var comment_score = comment[0]
		var comment_name = comment[1]
		var comment_text = bestellung.customer.comments.get(comment_name).items.pick_random()
		comment_bb+=comment_text+'\n'
	%comments.text="[ul]%s[/ul]"%comment_bb
	%rating.text="%.2f"%(score*100.0)+"%"
func _on_ok_pressed():
	super._on_ok_pressed()
	$/root/main.tutorial.set_variable(&"meal_submitted", 1)
	close.emit()
