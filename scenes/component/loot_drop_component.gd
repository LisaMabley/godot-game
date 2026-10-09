extends Node

@export_range(0, 1) var drop_percent: float = .70
@export var health_component: Node
@export var gem_scene: PackedScene
@export var health_drop_scene: PackedScene


func _ready():
	(health_component as HealthComponent).died.connect(_on_died)


func _on_died():
	if randf() > drop_percent:
		return

	_drop_health()


func _drop_gem():
	_spawn_drop(gem_scene)


func _drop_health():
	_spawn_drop(health_drop_scene)


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
