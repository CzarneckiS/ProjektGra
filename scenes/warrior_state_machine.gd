extends StateMachine

func _ready():
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	call_deferred("set_state", states.idle)
	


func _state_logic(delta):
		match state:
			states.idle:
				pass
			states.moving:
				parent.move_to_target(delta, parent.move_target)
			states.engaging:
				pass
			states.attacking:
				pass
			states.dying:
				pass

func _enter_state(_new_state, _previous_state):
		match state:
			states.idle:
				pass
			states.moving:
				pass
				#if parent.velocity.x > 0:
					#if $"../Sprite2D".scale.x > 0:
						#$"../Sprite2D".scale.x *= -1
				#elif parent.velocity.x < 0:
					#if $"../Sprite2D".scale.x > 0:
						#$"../Sprite2D".scale.x *= -1
			states.engaging:
				pass
			states.attacking:
				pass
			states.dying:
				pass

func _get_transition(_delta):
		match state:
			states.idle:
				pass
			states.moving:
				if parent.global_position.distance_to(parent.move_target) < parent.stop_distance:
					parent.move_target = parent.global_position
					set_state(states.idle)
			states.engaging:
				pass
			states.attacking:
				pass
			states.dying:
				pass

func _on_move_timer_timeout() -> void:
	if parent.get_slide_collision_count():
		if abs(parent.last_position.distance_to(parent.move_target)) < \
		abs(parent.global_position.distance_to(parent.move_target) + parent.move_treshold):
			parent.move_target = parent.global_position
			set_state(states.idle)
