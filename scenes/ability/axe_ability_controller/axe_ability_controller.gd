extends Node

@export var axe_ability_scene: PackedScene

var damage = 8


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	#GameEvents.ability_upgrade_added.connect(_on_ability_upgrade_added)


func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
#
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	if foreground_layer == null:
		return
	
	var axe_instance = axe_ability_scene.instantiate() as AxeAbility
	foreground_layer.add_child(axe_instance)
	axe_instance.hurtbox_component.damage = damage
	
	axe_instance.global_position = player.global_position
