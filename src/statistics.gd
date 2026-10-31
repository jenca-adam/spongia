class_name Statistics

const DISABLED_PROPS= ["_food_name_to_food_map"]

func _validate_property(property: Dictionary) -> void:
	if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.name not in DISABLED_PROPS:
		property.usage |= PROPERTY_USAGE_STORAGE

var total_orders= [0]

var average_score= [0.0]
var best_score= [0.0, "<nobody>"]
var worst_score= [0.0, "<nobody>"]
var best_customer= ["<nobody>", 0.0]
var worst_customer= ["<nobody>", 0.0]
var most_common_customer= ["<nobody>", 0]

var favourite_ingredient= ["<nothing>", 0.0]
var least_favourite_ingredient= ["<nothing>", 0.0]
var total_food_served= [0.0]

var total_cook_time= [0.0]
var total_cuts_made= [0]

var _customer_visits: Dictionary[String, int]={}
var _customer_avg_scores: Dictionary[String, float]={}

var _ingredient_usage: Dictionary[String, float]={}
var _food_name_to_food_map: Dictionary[StringName, Food]

func _refresh():
	# dirty trick
	best_customer[1]=-1
	worst_customer[1]=INF
	favourite_ingredient[1]=-1
	least_favourite_ingredient[1]=INF

	for customer_name in _customer_visits:
		if _customer_visits[customer_name]>most_common_customer[1] or most_common_customer[0] == "<nobody>":
			most_common_customer[0]=customer_name
			most_common_customer[1]=_customer_visits[customer_name]
	for customer_name in _customer_avg_scores:
		if _customer_avg_scores[customer_name]>best_customer[1] or best_customer[0] == "<nobody>":
			best_customer[0]=customer_name
			best_customer[1]=_customer_avg_scores[customer_name]
		if _customer_avg_scores[customer_name] < worst_customer[1] or worst_customer[0] == "<nobody>":
			worst_customer[0]=customer_name
			worst_customer[1]=_customer_avg_scores[customer_name]
	for ingredient_name in _ingredient_usage:
		if _ingredient_usage[ingredient_name]>favourite_ingredient[1] or favourite_ingredient[0] == "<nothing>":
			favourite_ingredient[0]=ingredient_name
			favourite_ingredient[1]=_ingredient_usage[ingredient_name]
		if _ingredient_usage[ingredient_name] < least_favourite_ingredient[1] or least_favourite_ingredient[0] == "<nothing>":
			least_favourite_ingredient[0]=ingredient_name
			least_favourite_ingredient[1]=_ingredient_usage[ingredient_name]

func setup(foods: Array[Food], customers: Array[Customer], food_map: Dictionary[StringName, Food]):
	_food_name_to_food_map=food_map
	for food in foods:
		if not _ingredient_usage.has(str(food.name)):
			_ingredient_usage[str(food.name)]=0.0
	for customer in customers:
		var key= str(customer.name)
		if not _customer_visits.has(key):
			_customer_visits[key]=0
			_customer_avg_scores[key]=0.0
	_refresh()

func log_result(order: Bestellung, items: Array[Cuttable], score: float):
	var customer_name= str(order.customer.name)
	_customer_visits[customer_name] += 1
	var visits=_customer_visits[customer_name]
	_customer_avg_scores[customer_name]=(_customer_avg_scores[customer_name] * (visits - 1) + score) / visits
	for item in items:
		var food_name= str(_food_name_to_food_map[item.type].name)
		_ingredient_usage[food_name] += item.volume
		total_food_served[0] += item.volume
	total_orders[0] += 1
	average_score[0]=(average_score[0] * (total_orders[0] - 1) + score) / total_orders[0]
	if score>best_score[0] or best_score[1] == "<nobody>":
		best_score[0]=score
		best_score[1]=order.selected_customer_name
	if score < worst_score[0] or worst_score[1] == "<nobody>":
		worst_score[0]=score
		worst_score[1]=order.selected_customer_name
	_refresh()

func log_cut():
	total_cuts_made[0] += 1

func log_cook_frame(delta: float):
	total_cook_time[0] += delta
