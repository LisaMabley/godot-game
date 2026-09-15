extends CharacterBody2D

const MAX_SPEED = 25

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("enemy")


func _process(_delta: float) -> void:
	var direction = _get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()


func _get_direction_to_player():
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
