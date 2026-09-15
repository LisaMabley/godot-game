extends Node
class_name HealthComponent

signal died

@export var max_health: float = 5
var current_health

func _ready() -> void:
	current_health = max_health


func _damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	Callable(_check_death).call_deferred()


func _check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
	
