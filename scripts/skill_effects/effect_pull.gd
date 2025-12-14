extends Effect
class_name EffectPull

@export var pull_friction: float
@export var pull_speed: float
var pull_velocity: Vector2

func apply_push(attack_position: Vector2, body):
	var pull_direction: Vector2 = (attack_position - body.global_position).normalized()
	body.push_velocity = pull_direction * pull_speed
	body.push_friction = pull_friction
	
	body.state_machine.set_state(body.state_machine.states.push)
