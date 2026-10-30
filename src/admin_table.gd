extends Node3D

func get_food_items() -> Array[Cuttable]:
	var containers := get_food_containers()
	var food_items: Array[Cuttable] = []
	for container in containers:
		container.freed_clear()
		food_items.append_array(container.bodies)
	return food_items

func get_taste_profile() -> TasteProfile:
	var food_items = get_food_items()
	var taste_profile := TasteProfile.new()
	taste_profile.setup()
	if food_items.size()==0:
		return taste_profile
	var total_volume = 0.;
	var max_volume = 0.;
	var cum_cook_time = 0.;
	var cum_vector = TasteVector.new()
	for item in food_items:
		total_volume+=item.volume
		cum_cook_time+=item.cook_time*item.volume
		max_volume = max(max_volume, item.volume)
		### dirty hack incoming!!!
		cum_vector.weighted_add($/root/main/ui_chest.food_resources[item.type].taste_vector.salted(item.added_salt/item.volume), item.volume)
	if total_volume>0:
		cum_vector.divide(total_volume)
		taste_profile.cook_time = min(120, cum_cook_time/total_volume) # clamp at 120 to make score calculation easier
		taste_profile.texture = max_volume/total_volume # not sure how to approach this
	taste_profile.taste_vector=cum_vector
	taste_profile.amount=min(5, total_volume) #not sure how you get 5 liters but ok 
	return taste_profile

func get_food_containers() -> Array[ObjContainer]:
	var containers: Array[ObjContainer] = []
	for area in $done_check.get_overlapping_areas():
		var container = area.get_parent() as ObjContainer
		if container == null:
			continue
		containers.append(container)
	return containers

func clear():
	var items=get_food_items()
	for item in items:
		item.queue_free()
