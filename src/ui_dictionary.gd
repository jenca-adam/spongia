extends Control
@export var page_flip_time:=0.5
@export var page_flip_ease:=Tween.EASE_OUT
var current_page=1
var turning = false
func _ready():
	for page in %left.get_children()+%right.get_children():
		page.z_index=3 # above both page texture rects
func _on_next_pressed() -> void:
	var curr_left:RichTextLabel = %left.get_node("%d"%current_page)
	var curr_right:RichTextLabel = %right.get_node("%d"%current_page)
	var next_left:RichTextLabel = %left.get_node_or_null("%d"%(current_page+1))
	var next_right:RichTextLabel = %right.get_node_or_null("%d"%(current_page+1))
	if not next_left or not next_right or turning:
		return
	turning = true
	var tween=get_tree().create_tween()
	tween.set_parallel(true)
	curr_left.offset_transform_enabled=true
	curr_right.offset_transform_enabled=true
	next_left.offset_transform_enabled=true
	next_right.offset_transform_enabled=true
	var left_width  =%left.size.x
	var right_width = %right.size.x
	next_left.offset_transform_pivot=Vector2((left_width/2),0)
	next_right.offset_transform_pivot=Vector2(-right_width/2,0)
	next_left.offset_transform_scale=Vector2(0,1)
	next_right.offset_transform_scale=Vector2(1,1)
	curr_left.z_index=1
	next_right.z_index=1
	next_left.show()
	next_right.show()
	tween.set_ease(page_flip_ease)
	tween.tween_property(curr_right, "offset_transform_scale", Vector2(0,1), page_flip_time)
	curr_right.offset_transform_pivot=Vector2(-right_width/2,0)
	tween.tween_property(%right_page, "offset_transform_scale", Vector2(0,1), page_flip_time)
	%left_page.offset_transform_scale=Vector2(0,1)
	var flip_left = func():
		var tween2=get_tree().create_tween()
		tween2.set_parallel(true)
		tween2.set_ease(page_flip_ease)
		tween2.tween_property(%left_page, "offset_transform_scale", Vector2(1,1), page_flip_time)
		tween2.tween_property(next_left, "offset_transform_scale", Vector2(1,1), page_flip_time)
	var reset = func():
		next_right.z_index=3
		%right_page.offset_transform_scale=Vector2(1,1)
		curr_left.hide()
		curr_right.hide()
		turning=false
	get_tree().create_timer(page_flip_time).timeout.connect(flip_left)
	get_tree().create_timer(2*page_flip_time).timeout.connect(reset)
	current_page+=1
	$turn.play()

func _on_prev_pressed() -> void:
	var curr_left:RichTextLabel = %left.get_node("%d"%current_page)
	var curr_right:RichTextLabel = %right.get_node("%d"%current_page)
	var next_left:RichTextLabel = %left.get_node_or_null("%d"%(current_page-1))
	var next_right:RichTextLabel = %right.get_node_or_null("%d"%(current_page-1))
	if not next_left or not next_right or turning:
		return
	turning=true
	var tween=get_tree().create_tween()
	tween.set_parallel(true)
	curr_left.offset_transform_enabled=true
	curr_right.offset_transform_enabled=true
	next_left.offset_transform_enabled=true
	next_right.offset_transform_enabled=true
	var left_width  =%left.size.x
	var right_width = %right.size.x
	next_left.offset_transform_pivot=Vector2((left_width/2),0)
	next_right.offset_transform_pivot=Vector2(-right_width/2,0)
	next_right.offset_transform_scale=Vector2(0,1)
	next_left.offset_transform_scale=Vector2(1,1)
	curr_right.z_index=1
	next_left.z_index=1
	next_left.show()
	next_right.show()
	tween.set_ease(page_flip_ease)
	curr_left.offset_transform_pivot=Vector2(left_width/2,0)
	tween.tween_property(curr_left, "offset_transform_scale", Vector2(0,1), page_flip_time)
	
	tween.tween_property(%left_page, "offset_transform_scale", Vector2(0,1), page_flip_time)
	%right_page.offset_transform_scale=Vector2(0,1)
	var flip_right = func():
		var tween2=get_tree().create_tween()
		tween2.set_parallel(true)
		tween2.set_ease(page_flip_ease)
		tween2.tween_property(%right_page, "offset_transform_scale", Vector2(1,1), page_flip_time)
		tween2.tween_property(next_right, "offset_transform_scale", Vector2(1,1), page_flip_time)
	var reset = func():
		next_left.z_index=3
		%left_page.offset_transform_scale=Vector2(1,1)
		curr_left.hide()
		curr_right.hide()
		turning=false
	get_tree().create_timer(page_flip_time).timeout.connect(flip_right)
	get_tree().create_timer(2*page_flip_time).timeout.connect(reset)
	current_page-=1
	$turn.play()


func _on_close_pressed() -> void:
	hide()
