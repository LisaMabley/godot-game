extends Area2D
class_name HitboxComponent

@export var health_component: Node


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D):
	if not other_area is HurtboxComponent:
		return

	if health_component == null:
		return

	var hurtbox_component = other_area as HurtboxComponent
	health_component.damage(hurtbox_component.damage)
