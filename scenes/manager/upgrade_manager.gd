extends Node

@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}


func _ready() -> void:
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
	
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func _pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var available_upgrades = upgrade_pool.duplicate()
	for i in 2:
		var chosen_upgrade = available_upgrades.pick_random() as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
		available_upgrades = available_upgrades.filter(func (upgrade): return upgrade.id != chosen_upgrade.id)
	
	return chosen_upgrades


func _on_upgrade_selected(upgrade: AbilityUpgrade):
	_apply_upgrade(upgrade)


func _on_level_up(_current_level: int):
	var upgrade_scene_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_scene_instance)
	var available_upgrades = _pick_upgrades()
	upgrade_scene_instance.set_ability_upgrades(available_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(_on_upgrade_selected)
