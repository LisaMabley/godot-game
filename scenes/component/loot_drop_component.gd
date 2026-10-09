extends Node

@export_range(0, 1) var drop_percent: float = .70
@export var health_component: Node
@export var loot_table: LootDropTable

var weighted_table = WeightedTable.new()


func _ready() -> void:
	if loot_table == null or loot_table.entries.is_empty():
		push_error("LootDropComponent requires a loot table with at least one entry.")
		return

	for index in loot_table.entries.size():
		var entry = loot_table.entries[index]
		if entry == null or entry.drop_scene == null or entry.weight <= 0:
			push_error("LootDropComponent has an invalid loot table entry at index %d." % index)
			return

		weighted_table.add_item(entry.drop_scene, entry.weight, str(index))

	(health_component as HealthComponent).died.connect(_on_died)


func _on_died():
	if randf() > drop_percent:
		return

	_spawn_drop(weighted_table.pick_item())


func _spawn_drop(drop_scene: PackedScene):
	if drop_scene == null:
		push_error("LootDropComponent has no drop scene assigned.")
		return

	if not owner is Node2D:
		return

	var spawn_position = (owner as Node2D).global_position
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	var drop = drop_scene.instantiate() as Node2D
	entities_layer.add_child(drop)
	drop.global_position = spawn_position
