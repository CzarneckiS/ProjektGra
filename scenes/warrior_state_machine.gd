extends StateMachine

func _ready():
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	add_state("swinging")
	#to po prostu oznacza ze startujemy ze statem idle jak cos, call deferred wywoluje sie jako ostatni
	#kiedy juz inne states sie ladnie dodadza do list i wglaaa
	call_deferred("set_state", states.idle)
	#trzeba bedzie dodac kolejny stan - returning; kiedy jednostka odejdzie za daleko od glownej postaci
	#to niewazne co robila wraca do nas


func _state_logic(delta):
		match state:
			states.idle:
				pass
			states.moving:
				parent.move_to_target(delta, parent.move_target)
			states.engaging:
				if parent.closest_enemy_within_attack_range() == null:
					parent.move_to_target(delta, parent.attack_target.get_ref().global_position)
			states.attacking:
				$"../AnimationPlayer".play("attack")
			states.dying:
				pass
			states.swinging:
				pass

func _enter_state(new_state, previous_state):
		match state:
			states.idle:
				$"../AnimationPlayer".play("idle")
			states.moving:
				#placeholder zmieniania animacji - troche zwalone jest bo trzeba 2 razy kliknac?
				#jak ktos wie czemu to feel free poprawic
				$"../AnimationPlayer".play("walk")
				if parent.velocity.x > 0:
					if $"../Sprite2D".scale.x > 0:
						$"../Sprite2D".scale.x *= -1
				elif parent.velocity.x < 0:
					if $"../Sprite2D".scale.x < 0:
						$"../Sprite2D".scale.x *= -1
			states.engaging:
				$"../AnimationPlayer".play("walk")
				if parent.velocity.x > 0:
					if $"../Sprite2D".scale.x > 0:
						$"../Sprite2D".scale.x *= -1
				elif parent.velocity.x < 0:
					if $"../Sprite2D".scale.x < 0:
						$"../Sprite2D".scale.x *= -1
			states.attacking:
				pass
			states.dying:
				pass

#chyba trza stworzyc dodatkowy var w szkielecie - clicked_enemy i szkielet ma do niego isc i go bic
#i jesli clicked_enemy != null nie rozgladaj sie za innymi pobliskimi przeciwnikami
func _get_transition(delta):
		match state:
			states.idle:
				if parent.closest_enemy() != null:
					parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.engaging)
			states.moving:
				#jesli jednostka dojdzie do celu (a bardziej znajdzie sie w odleglosci mniejszej
				#niz jakas tam wartosc stop distance) to sie zatrzyma i zacznie idlowac
				if parent.global_position.distance_to(parent.move_target) < parent.stop_distance:
					parent.move_target = parent.global_position
					set_state(states.idle)
			states.engaging:
				#Jesli nasz cel znajdzie sie w naszym zasiegu ataku zacznij atakowac
				if parent.closest_enemy_within_attack_range() != null:
					parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.attacking)
			states.attacking:
				if $"../AnimationPlayer".get_current_animation() == "attack":
					set_state(states.swinging)
				#elif parent.closest_enemy_within_attack_range() == null:
					#set_state(states.engaging)
			states.dying:
				pass
			states.swinging:
				if $"../AnimationPlayer".is_playing(): return 
				else:
					#set_state(states.engaging)
					if parent.closest_enemy_within_attack_range() != null:
						parent.attack_target = weakref(parent.closest_enemy())
						set_state(states.attacking)
					else:
						set_state(states.engaging)

func _on_move_timer_timeout() -> void:
	if parent.get_slide_collision_count():
		if abs(parent.last_position.distance_to(parent.move_target)) < \
		abs(parent.global_position.distance_to(parent.move_target) + parent.move_treshold):
			parent.move_target = parent.global_position
			set_state(states.idle)
