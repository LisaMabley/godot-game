class_name WeightedTable

var items: Array[Dictionary] = []
var weight_sum = 0


func add_item(item, weight: int, id: String):
	items.append({ "item": item, "weight": weight, "id": id })
	weight_sum += weight


func update_item_weight(id_to_update, new_weight: int):
	for item in items:
		if item.id == id_to_update:
			item["weight"] = new_weight


func pick_item():
	var chosen_weight = randi_range(1, weight_sum)
	var iteration_sum = 0
	for item in items:
		iteration_sum += item["weight"]
		if chosen_weight <= iteration_sum:
			return item["item"]
