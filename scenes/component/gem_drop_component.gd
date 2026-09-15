extends Node

@export_range(0, 1) var drop_percent: float = .70
@export var health_component: Node
@export var gem_scene: PackedScene


func _ready():
	(health_component as HealthComponent).died.connect(_on_died)


func _on_died():
	if randf() > drop_percent:
		return
	
	if gem_scene == null:
		return
	
	if not owner is Node2D:
		return
		
	var spawn_position = (owner as Node2D).global_position
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	var gem_earned = gem_scene.instantiate() as Node2D
	entities_layer.add_child(gem_earned)
	gem_earned.global_position = spawn_position
	
