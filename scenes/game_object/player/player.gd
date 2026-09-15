extends CharacterBody2D

const MAX_SPEED = 75
const ACCELERATION_SMOOTHING = 25

@onready var damage_interval_timer = $DamageIntervalTimer

var number_of_attackers = 0

func _ready() -> void:
	add_to_group("player")
	$HitboxArea.body_entered.connect(_on_hitbox_area_body_entered)
	$HitboxArea.body_exited.connect(_on_hitbox_area_body_exited)
	damage_interval_timer.timeout.connect(_on_damage_interval_timer_timeout)


func _process(delta: float) -> void:
	var movement_vector = _get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()


func _get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)


func _check_deal_damage():
	if number_of_attackers == 0 || !damage_interval_timer.is_stopped():
		return
	$HealthComponent._damage(1)
	print($HealthComponent.current_health)
	damage_interval_timer.start()


func _on_hitbox_area_body_entered(other_body: Node2D):
	number_of_attackers +=1
	_check_deal_damage()


func _on_hitbox_area_body_exited(other_body: Node2D):
	number_of_attackers -=1


func _on_damage_interval_timer_timeout():
	_check_deal_damage()
