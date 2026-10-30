class_name Statistics
extends Object
var total_orders:=[0]

var average_score:=[0.0]
var best_score:=[0.0, "<nobody>"]
var worst_score:=[0.0, "<nobody>"]
var best_customer:=["<nobody>", 0.0]
var worst_customer:=["<nobody>", 0.0]
var most_common_customer:=["<nobody>", 0]

var favourite_ingredient:=["<nothing>", 0.0]
var least_favourite_ingredient:=["<nothing>", 0.0]
var total_food_served:=[0.0]

var total_cook_time:=[0.0]
var total_cuts_made:=[0]

var _customer_visits:Dictionary[Customer, int] = {}
var _customer_avg_scores:Dictionary[Customer, float] = {}

var _ingredient_usage:Dictionary[Food, float] = {}
var _food_name_to_food_map:Dictionary[StringName, Food]

func _refresh():
	# dirty trick
	best_customer[1]=-1
	worst_customer[1]=INF
	favourite_ingredient[1]=-1
	least_favourite_ingredient[1]=INF
	
	for customer in _customer_visits:
		if _customer_visits[customer]>most_common_customer[1] or most_common_customer[0]=="<nobody>":
			most_common_customer[0]=customer.name
			most_common_customer[1]=_customer_visits[customer]
	for customer in _customer_avg_scores:
		if _customer_avg_scores[customer]>best_customer[1] or best_customer[0]=="<nobody>":
			best_customer[0]=customer.name
			best_customer[1]=_customer_avg_scores[customer]
		if _customer_avg_scores[customer]<worst_customer[1] or worst_customer[0]=="<nobody>":
			worst_customer[0]=customer.name
			worst_customer[1]=_customer_avg_scores[customer]
	for ingredient in _ingredient_usage:
		if _ingredient_usage[ingredient]>favourite_ingredient[1] or favourite_ingredient[0]=="<nothing>":
			favourite_ingredient[0]=ingredient.name
			favourite_ingredient[1]=_ingredient_usage[ingredient]
		if _ingredient_usage[ingredient]<least_favourite_ingredient[1] or least_favourite_ingredient[0]=="<nothing>":
			least_favourite_ingredient[0]=ingredient.name
			least_favourite_ingredient[1]=_ingredient_usage[ingredient]
func setup(foods:Array[Food], customers:Array[Customer], food_map:Dictionary[StringName, Food]):
	_food_name_to_food_map=food_map
	for food in foods:
		_ingredient_usage[food] = 0.0
	for customer in customers:
		_customer_visits[customer] = 0
		_customer_avg_scores[customer] = 0.0
	_refresh()
func log_result(order:Bestellung, items:Array[Cuttable], score:float):
	_customer_visits[order.customer]+=1
	var visits = _customer_visits[order.customer]
	_customer_avg_scores[order.customer]=(_customer_avg_scores[order.customer]*(visits-1)+score)/visits
	for item in items:
		var food= _food_name_to_food_map[item.type]
		_ingredient_usage[food]+=item.volume
		total_food_served[0] += item.volume
	total_orders[0]+=1
	average_score[0]=(average_score[0]*(total_orders[0]-1)+score)/total_orders[0]
	if score>best_score[0] or best_score[1]=="<nobody>":
		best_score[0]=score
		best_score[1]=order.selected_customer_name
	if score<worst_score[0] or worst_score[1]=="<nobody>":
		worst_score[0]=score
		worst_score[1]=order.selected_customer_name
	_refresh()
func log_cut():
	total_cuts_made[0]+=1
func log_cook_frame(delta:float):
	total_cook_time[0]+=delta
