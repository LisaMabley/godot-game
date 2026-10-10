extends Area2D
class_name HitboxComponent

@export var health_component: Node

var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D):
	if not other_area is HurtboxComponent:
		return

	if health_component == null:
		return

	var hurtbox_component = other_area as HurtboxComponent
	var enemy_damage_dealt = hurtbox_component.damage
	health_component._damage(enemy_damage_dealt)
	
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	floating_text.global_position = global_position + (Vector2.UP * 16)
	
	floating_text.start(str(enemy_damage_dealt))
