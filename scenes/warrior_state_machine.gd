extends StateMachine

@onready var sprite_root = $"../Sprite2D" #root sprite'ów jednostki do obracania jej
@onready var animation_player = $"../AnimationPlayer"

func _ready():
	#dodawanie naszych stanów do słownika
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	add_state("mid_animation")
	#to po prostu oznacza ze startujemy ze statem idle jak cos, call deferred wywoluje sie jako ostatni
	#kiedy juz inne states sie ladnie dodadza do list i wglaaa
	call_deferred("set_state", states.idle)
	#trzeba bedzie dodac kolejny stan - returning; kiedy jednostka odejdzie za daleko od glownej postaci
	#to niewazne co robila, wraca do nas

#Rozkazy dla jednostki wykonywane w physics_process
func _state_logic(delta):
		match state: #sprawdź w którym stanie teraz jesteś
			states.idle:
				pass #jeśli jesteś idle to nic nie robisz
			states.moving:
				parent.move_to_target(delta, parent.move_target) #idź do celu (nie przeciwnik)
			states.engaging:
				if parent.attack_target.get_ref(): #jeśli cel (jednostka) istnieje, idź do niego
					parent.move_to_target(delta, parent.attack_target.get_ref().global_position)
			states.attacking:
				animation_player.play("attack") #Jeśli zaczniesz atakować, zagraj animacje ataku
			states.dying:
				pass
			states.mid_animation:
				pass

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
				#placeholder zmieniania animacji - troche zwalone jest bo trzeba 2 razy kliknac?
				#jak ktos wie czemu to feel free poprawic
				animation_player.play("walk")
				if parent.velocity.x > 0:
					if sprite_root.scale.x > 0:
						sprite_root.scale.x *= -1
				elif parent.velocity.x < 0:
					if sprite_root.scale.x < 0:
						sprite_root.scale.x *= -1
			states.engaging:
				animation_player.play("walk")
				if parent.velocity.x > 0:
					if sprite_root.scale.x > 0:
						sprite_root.scale.x *= -1
				elif parent.velocity.x < 0:
					if sprite_root.scale.x < 0:
						sprite_root.scale.x *= -1
			states.attacking:
				pass
			states.dying:
				animation_player.play("dying") #Kiedy wejdziesz w state, rozpocznij animację
			states.mid_animation:
				pass

#Warunki przejścia do nowego stanu - wykonywane PO state_logic
func _get_transition(_delta):
		match state:
			states.idle: #kiedy nic nie robisz
				if parent.closest_enemy() != null: #jeśli jest jakiś przeciwnik w wizji
					parent.attack_target = weakref(parent.closest_enemy()) #obierz go za cel
					set_state(states.engaging) #zacznij do niego iść
			states.moving: #przemieszczanie się do celu na ziemi
				#jesli jednostka dojdzie do celu (a bardziej znajdzie sie w odleglosci mniejszej
				#niz jakas tam wartosc stop distance) to sie zatrzyma i zacznie idlowac
				if parent.global_position.distance_to(parent.move_target) < parent.stop_distance:
					parent.move_target = parent.global_position
					set_state(states.idle)
			states.engaging: #przemieszczanie się w stronę przeciwnika
				#parent.speed = 600 #do debugowania rightclicka, cos na wysokim speedzie sie wali i jednoski przenikaja przez inne?
				if parent.attack_target_within_attack_range() != null: #Jesli cel znajdzie sie w zasiegu ataku
					parent.attack_target = weakref(parent.closest_enemy()) #obierz go za cel
					#parent.speed = 300 #debug
					set_state(states.attacking) #zacznij atakować
				if !parent.attack_target.get_ref(): #jeśli nie masz celu
					#parent.speed = 300 #debug
					set_state(states.idle) #zacznij idlować
			states.attacking:
				#jeśli uda ci się zacząć atak przejdź w stan wykonywania animacji
				if animation_player.get_current_animation() == "attack":
					set_state(states.mid_animation)
			states.dying: #Dopóki odgrywasz animację umierania, nic nie rób
				if animation_player.is_playing(): return
				else: #kiedy się skończy, przestań istnieć
					parent.queue_free()
			states.mid_animation: #Dopóki odgrywasz animację atakowania, nic nie rób
				if animation_player.is_playing(): return 
				else: #kiedy skończysz sprawdź czy cel wciąż jest w zasięgu ataku
					if parent.attack_target_within_attack_range() != null:
						set_state(states.attacking) #jeśli jest to go atakuj
					else:
						set_state(states.engaging) #jeśli nie to go goń
						#jeśli cel umarł to w stanie engaging to sprawdzi i przejdzie do idle

#temporary do movementu
func _on_move_timer_timeout() -> void:
	if parent.get_slide_collision_count():
		if abs(parent.last_position.distance_to(parent.move_target)) < \
		abs(parent.global_position.distance_to(parent.move_target) + parent.move_treshold):
			parent.move_target = parent.global_position
			set_state(states.idle)
