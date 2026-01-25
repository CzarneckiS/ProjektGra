extends StateMachine

@onready var sprite_root = $"../Sprite2D" #root sprite'ów jednostki do obracania jej
@onready var animation_player = $"../AnimationPlayer"

func _ready():
	#dodawanie naszych stanów do słownika
	add_state("idle") #0
	add_state("moving") #1
	add_state("dying") #2
	add_state("mid_animation") #3
	#to po prostu oznacza ze startujemy ze statem idle jak cos, call deferred wywoluje sie jako ostatni
	#kiedy juz inne states sie ladnie dodadza do słownia
	call_deferred("set_state", states.idle)
	dying_state = states.dying

#quick 'n' dirty 'n' nasty fix zeby jednostki mniej wibrowaly kiedy sa bodyblockowane
#tutaj musi byc 0, zeby nie bylo delayu przy wydawaniu rozkazu
var turn_left_timer = 0
var turn_right_timer = 0

#male decision tree do wybierania akcji
#wartosc to szansa w procentach
var action_cooldown : float = 0
func set_action_cooldown(shortened: bool):
	if shortened:
		action_cooldown = randf_range(0.5, 0.7)
	else:
		action_cooldown = randf_range(2, 3)
var fire_wave_probability : int = 20
var homing_projectile_probability : int = 20
var explosion_probability : int = 20
var reposition_probability : int = 20
var basic_attack_probability : int = 20
var previous_action
var probability_array : Array[int] = [
	fire_wave_probability,
	homing_projectile_probability,
	explosion_probability,
	reposition_probability,
	basic_attack_probability
]
func prob_sum(index) -> int:
	var sum : int = 0
	for i in range(index):
		sum += probability_array[i]
	return sum
func set_new_probability(index):
	for i in probability_array.size():
		probability_array[i] += 1
	probability_array[index] -= 5
func choose_action():
	var random_number = randi_range(1, 100)
	if random_number >= prob_sum(4) and previous_action != &"melee_attack" and previous_action != &"ranged_attack":
		set_new_probability(4)
		parent.attack_target = weakref(parent.closest_enemy())
		if parent.closest_enemy_within_attack_range() != null:
			previous_action = &"melee_attack"
			set_state(states.mid_animation)
		else:
			previous_action = &"ranged_attack"
			parent.closest_enemy()
			set_state(states.mid_animation)
		set_action_cooldown(false) #false = standardowy czas
	elif random_number >= prob_sum(3) and previous_action != &"reposition":
		set_new_probability(3)
		var units_close : bool = false
		for unit in parent.possible_targets:
			if !unit:
				continue
			if unit.global_position.distance_to(parent.global_position) < 300:
				units_close = true
		previous_action = &"reposition"
		if units_close:
			parent.attack_target = weakref(parent.closest_enemy())
			if parent.closest_enemy_within_attack_range() != null:
				previous_action = &"melee_attack"
				set_state(states.mid_animation)
				set_action_cooldown(false) #false = standardowy czas
			else:
				set_action_cooldown(true) #true = czas skrocony
		else:
			var target_point : Vector2 = get_random_point_in_radius(300)
			set_state(states.moving)
			parent.move_target = target_point
			set_action_cooldown(false) #false = standardowy czas
	elif random_number >= prob_sum(2) and previous_action != &"explosion":
		#parent.cast_explosive_circle_single() w enter_state mid_animation
		set_new_probability(2)
		previous_action = &"explosion"
		set_action_cooldown(false) #false = standardowy czas
		set_state(states.mid_animation)
	elif random_number >= prob_sum(1) and previous_action != &"homing":
		#parent.cast_homing_projectile(4) w srodku animacji
		set_new_probability(1)
		previous_action = &"homing"
		set_action_cooldown(false) #false = standardowy czas
		set_state(states.mid_animation)
	elif previous_action != &"firewave":
		#parent.cast_fire_wave_single() w srodku animacji
		set_new_probability(0)
		previous_action = &"firewave"
		set_action_cooldown(false) #false = standardowy czas
		set_state(states.mid_animation)
	else:
		choose_action()

func is_point_on_map(target_point: Vector2) -> bool:
	var map = parent.get_world_2d().navigation_map
	var closest_point = NavigationServer2D.map_get_closest_point(map, target_point)
	var difference = closest_point - target_point
	if difference.is_zero_approx():
		return true
	else:
		return false
func get_random_point_in_radius(radius: int) -> Vector2:
	var point := Vector2(randf_range(parent.global_position.x-radius, parent.global_position.x+radius),\
	randf_range(parent.global_position.y-radius, parent.global_position.y+radius))
	while !is_point_on_map(point):
		point = Vector2(randf_range(parent.global_position.x-radius, parent.global_position.x+radius),\
	randf_range(parent.global_position.y-radius, parent.global_position.y+radius))
	return point

#Rozkazy dla jednostki wykonywane w physics_process
func _state_logic(delta):
	action_cooldown -= delta
	match state: #sprawdź w którym stanie teraz jesteś
		states.idle:
			pass
		states.moving:
			if parent.closest_enemy() == null:
				parent.move_target = Globals.player_position
			parent.move_to_target(delta, parent.move_target) #idź do celu (nie przeciwnik)
			if parent.velocity.x > 0: #turn right
				turn_left_timer = 0.1
				if turn_right_timer > 0:
					turn_right_timer -= delta
				if sprite_root.scale.x > 0 and turn_right_timer <= 0:
					sprite_root.scale.x *= -1
			elif parent.velocity.x < 0: #turn left
				turn_right_timer = 0.1
				if turn_left_timer > 0:
					turn_left_timer -= delta
				if sprite_root.scale.x < 0 and turn_left_timer <= 0:
					sprite_root.scale.x *= -1
		states.dying:
			pass
		states.mid_animation:
			if previous_action == &"reposition":
				parent.move_to_target(delta, parent.move_target)

func _enter_state(_new_state, _previous_state):
		match state:
			states.idle:
				animation_player.play("idle")
				parent.get_node("Sprite2D/Body").stop() #animacja nóg
			states.moving:
				parent.reset_stuck_pathfinding_timer() #proper reset wszystkich zmiennych
				animation_player.play("walk")
				parent.get_node("Sprite2D/Body").play("default") #animacja nóg
			states.dying:
				animation_player.play("dying") #Kiedy wejdziesz w state, rozpocznij animację
				parent.get_node("Sprite2D/Body").stop() #animacja nóg
			states.mid_animation:
				parent.get_node("Sprite2D/Body").stop() #animacja nóg
				if previous_action == &"explosion":
					for unit in parent.possible_targets:
						parent.add_to_heatmap(unit.global_position)
					parent.best_chunk_position = parent.find_best_chunk()
					animation_player.play("casting_explosion")
					parent.cast_explosive_circle_single()
					if parent.best_chunk_position.x - parent.global_position.x  > 0: #turn right
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif parent.best_chunk_position.x - parent.global_position.x < 0: #turn left
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
				elif previous_action == &"firewave":
					animation_player.play("casting_firewave")
					if Globals.player_position.x - parent.global_position.x > 0: #turn right
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif Globals.player_position.x - parent.global_position.x < 0: #turn left
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
				elif previous_action == &"homing":
					animation_player.play("casting_homing")
					if Globals.player_position.x - parent.global_position.x > 0: #turn right
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif Globals.player_position.x - parent.global_position.x < 0: #turn left
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
				elif previous_action == &"melee_attack":
					animation_player.play("melee_attack")
					if parent.attack_target.get_ref().global_position.x - parent.global_position.x > 0: #turn right
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif parent.attack_target.get_ref().global_position.x - parent.global_position.x < 0: #turn left
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
				elif previous_action == &"ranged_attack":
					animation_player.play("ranged_attack")
					if parent.attack_target.get_ref().global_position.x - parent.global_position.x > 0: #turn right
						if sprite_root.scale.x > 0:
							sprite_root.scale.x *= -1
					elif parent.attack_target.get_ref().global_position.x - parent.global_position.x < 0: #turn left
						if sprite_root.scale.x < 0:
							sprite_root.scale.x *= -1
#Warunki przejścia do nowego stanu - wykonywane PO state_logic
func _get_transition(_delta):
		match state:
			states.idle: #kiedy nic nie robisz
				if parent.closest_enemy() != null: #jeśli jest jakiś przeciwnik w wizji
					if action_cooldown <= 0:
						choose_action()
				else: #jeśli NIE ma przeciwników w wizji
					set_state(states.moving)#idź w stronę gracza
			states.moving: #jeśli idziesz
				if parent.closest_enemy() != null: #jeśli jest jakiś przeciwnik w wizji
					if action_cooldown <= 0:
						choose_action()
				if parent.global_position.distance_to(parent.move_target) < parent.stop_distance:
					parent.move_target = parent.global_position
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
				if previous_action == &"charging":
					if parent.global_position.distance_to(parent.move_target) < parent.stop_distance:
						parent.move_target = parent.global_position
						set_state(states.idle)
				if animation_player.is_playing(): return 
				else: #kiedy skończysz sprawdź czy cel wciąż jest w zasięgu ataku
					set_state(states.idle)
