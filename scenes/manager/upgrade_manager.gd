extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_attack_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")


func _ready() -> void:
	upgrade_pool.add_item(upgrade_axe, 5, upgrade_axe.id)
	upgrade_pool.add_item(upgrade_sword_damage, 10, upgrade_sword_damage.id)
	upgrade_pool.add_item(upgrade_sword_rate, 10, upgrade_sword_rate.id)
	experience_manager.level_up.connect(_on_level_up)


func _apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10, upgrade_axe_damage.id)


func _pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	
	for i in 2:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades) as AbilityUpgrade
		if chosen_upgrade == null:
			break

		chosen_upgrades.append(chosen_upgrade)
	
	return chosen_upgrades


func _on_upgrade_selected(upgrade: AbilityUpgrade):
	_apply_upgrade(upgrade)


func _on_level_up(_current_level: int):
	var upgrade_scene_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_scene_instance)
	var available_upgrades = _pick_upgrades()
	upgrade_scene_instance.set_ability_upgrades(available_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(_on_upgrade_selected)
