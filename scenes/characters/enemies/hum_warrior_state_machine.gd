extends StateMachine

@onready var sprite_root = $"../Sprite2D" #root sprite'ów jednostki do obracania jej
@onready var animation_player = $"../AnimationPlayer"

func _ready():
	#dodawanie naszych stanów do słownika
	add_state("idle") #0
	add_state("moving") #1
	add_state("engaging") #2
	add_state("attacking") #3
	add_state("dying") #4
	add_state("mid_animation") #5
	add_state("push") #6
	#to po prostu oznacza ze startujemy ze statem idle jak cos, call deferred wywoluje sie jako ostatni
	#kiedy juz inne states sie ladnie dodadza do słownia
	call_deferred("set_state", states.idle)

#Rozkazy dla jednostki wykonywane w physics_process
func _state_logic(delta):
		match state: #sprawdź w którym stanie teraz jesteś
			states.idle:
				pass #jeśli jesteś idle to nic nie robisz
			states.moving:
				parent.move_target = Globals.player_position
				parent.move_to_target(delta, parent.move_target) #idź do celu (nie przeciwnik)
				if parent.velocity.x > 0:
					if sprite_root.scale.x > 0:
						sprite_root.scale.x *= -1
				elif parent.velocity.x < 0:
					if sprite_root.scale.x < 0:
						sprite_root.scale.x *= -1
			states.engaging:
				if parent.attack_target.get_ref(): #jeśli cel (jednostka) istnieje, idź do niego
					parent.move_to_target(delta, parent.attack_target.get_ref().global_position)
					if parent.velocity.x > 0:
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif parent.velocity.x < 0:
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
			states.attacking:
				if parent.attack_target.get_ref():
					if parent.global_position.x - parent.attack_target.get_ref().global_position.x < 0:
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif parent.global_position.x - parent.attack_target.get_ref().global_position.x > 0:
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
			states.dying:
				pass
			states.mid_animation:
				pass
			states.push:
				parent.push_velocity = parent.push_velocity.lerp(Vector2.ZERO, delta * parent.push_friction)
				parent.velocity = parent.push_velocity
				parent.move_and_slide()
				if parent.push_velocity.is_zero_approx():
					parent.push_velocity = Vector2.ZERO
					set_state(states.idle)
				
#Akcje wykonywane jednorazowo przy zmianie stanu PRZED state_logic
#DO POPRAWY ! - nie działają poprawnie
#enter state jest wykonywane PRZED state logic więc pytamy o nasz cel zeby zmienic kierunek
#spritow zanim w ogóle go znajdziemy - bad news
#Tylko dying jest poprawnym state
func _enter_state(_new_state, _previous_state):
		match state:
			states.idle:
				animation_player.play("idle")
			states.moving:
				animation_player.play("walk")
			states.engaging:
				animation_player.play("walk")
			states.attacking:
				pass
			states.dying:
				animation_player.play("dying") #Kiedy wejdziesz w state, rozpocznij animację
			states.push:
				animation_player.play("dying") #dla debuga
				#animation_player.play("walk") #dla debuga
				#if parent.velocity.x > 0:
					#if sprite_root.scale.x > 0:
						#sprite_root.scale.x *= -1
				#elif parent.velocity.x < 0:
					#if sprite_root.scale.x < 0:
						#sprite_root.scale.x *= -1
						
			states.mid_animation:
				pass
#Warunki przejścia do nowego stanu - wykonywane PO state_logic
func _get_transition(_delta):
		match state:
			states.idle: #kiedy nic nie robisz
				if parent.closest_enemy() != null: #jeśli jest jakiś przeciwnik w wizji
					parent.attack_target = weakref(parent.closest_enemy()) #obierz go za cel
					set_state(states.engaging) #zacznij do niego iść
				else: #jeśli NIE ma przeciwników w wizji
					 #idź w stronę gracza
					set_state(states.moving)
			states.moving: #jeśli idziesz w stronę gracza (bez wrogów w pobliżu)
				if parent.closest_enemy() != null: #ale znajdziesz przeciwnika
					parent.attack_target = weakref(parent.closest_enemy()) #obierz go za cel
					set_state(states.engaging) #i idź w jego stronę
			states.engaging: #jeśli idziesz w stronę przeciwnika
				if !parent.attack_target.get_ref(): #jeśli nie masz celu
					set_state(states.idle) #zacznij idlować
				elif parent.attack_target.get_ref().dying:
					parent.possible_targets.erase(parent.attack_target.get_ref())
					set_state(states.idle)
				elif parent.closest_enemy_within_attack_range() != null:
					#parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.attacking) # zacznij atakowac
			states.attacking:
				if parent.attack_target.get_ref():
					if !parent.attack_target.get_ref().dying:
						if parent.can_attack:
							animation_player.play("attack") #Jeśli zaczniesz atakować, zagraj animacje ataku
							set_state(states.mid_animation)
					else:
						parent.possible_targets.erase(parent.attack_target.get_ref())
						set_state(states.idle)
				else:
					set_state(states.idle)
			states.dying: #Dopóki odgrywasz animację umierania, nic nie rób
				if animation_player.is_playing(): return
				else: #kiedy się skończy, przestań istnieć
					if parent.mouse_hovering: #jeśli wciąż mamy kursor na przeciwniku
						Globals.remove_overlapping_enemies() #to przestań highlightować kursor
					Globals.update_player_exp(parent.experience_value) #wywolujemy funkcje z globalsow aby zaktualizowac exp gracza i przekazujemy zmeinna warrior_exp zdefiniowana w samym human warriorze
					parent.death()
					parent.queue_free()
			states.mid_animation: #Dopóki odgrywasz animację atakowania, nic nie rób
				if animation_player.is_playing(): return 
				else: #kiedy skończysz sprawdź czy cel wciąż jest w zasięgu ataku
					if parent.closest_enemy_within_attack_range() != null:
						parent.attack_target = weakref(parent.closest_enemy())
						set_state(states.attacking) #jeśli jest to go atakuj
					else:
						set_state(states.engaging) #jeśli nie to go goń
						#jeśli cel umarł to w stanie engaging to sprawdzi i przejdzie do idle
			states.push:
				if animation_player.is_playing(): return
				else:
					set_state(states.idle)
					
#temporary do movementu
#func _on_move_timer_timeout() -> void:
	#if parent.get_slide_collision_count():
		#if abs(parent.last_position.distance_to(parent.move_target)) < \
		#abs(parent.global_position.distance_to(parent.move_target) + parent.move_treshold):
			#parent.move_target = parent.global_position
			#set_state(states.idle)
