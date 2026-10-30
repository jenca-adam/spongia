class_name Bestellung
extends RefCounted

var customer:Customer
var selected_order_line:String
var selected_customer_name:String

static func from_customer(customer:Customer)->Bestellung:
	var bestellung = Bestellung.new()
	bestellung.customer = customer
	bestellung.selected_order_line = customer.orders.items.pick_random()
	bestellung.selected_customer_name = customer.names.items.pick_random()
	return bestellung
