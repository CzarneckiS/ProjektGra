extends Effect
class_name EffectKnockback

@export var knockback_friction: float
@export var knockback_speed: float
var push_velocity: Vector2

func apply_push(attack_position: Vector2, body):
	var knockback_direction: Vector2 = (body.global_position - attack_position).normalized()
	body.push_velocity = knockback_direction * knockback_speed
	body.push_friction = knockback_friction
	
	if body.state_machine.states.has("push"):
		body.state_machine.set_state(body.state_machine.states.push)
