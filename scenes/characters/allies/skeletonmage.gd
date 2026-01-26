extends UnitParent

var projectile = preload("res://resources/skeleton_mage_projectile.tres")

var skills_stat_up : Array = []
var skills_passive : Array = []
var skills_on_hit : Array = [projectile]
var skills_on_death : Array = []
var own_tags: PackedInt32Array = [Tags.UnitTag.UNIT, Tags.UnitTag.ALLIED, Tags.UnitTag.SKELETON_MAGE]
#movement
var speed = 355
var stop_distance = 30 #jak daleko ma sie zatrzymywac od swojego celu (state == moving)
const move_treshold = 0.5 #temporary, bedzie wymienione przy pathfindingu
var last_position = Vector2.ZERO #temporary, bedzie wymienione przy pathfindingu
var next_path_position
var can_navigate:bool = true
var follow_distance_idle:int = 700
var follow_distance_absolute:int = 1200
var movement_order #rozkaz tworzony w levelu przy right clickowaniu

#combat
var base_damage = 15
var damage = base_damage
var attack_target #ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UZYWAJCIE .get_ref()
var possible_targets = [] #jednostki ktore wejda w VisionArea
const attack_range = 400
const vision_range = 500
var dying : bool = false
var attack_speed_modifier = 1 #wykorzystywany w state machine
#selecting
var selected: bool = false
var mouse_hovering:bool = false



var state_machine
@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var unstick_timer: Timer = $Timers/UnstickTimer

func _ready() -> void:
	unit_hud_order = 1
	icon_texture = "res://sprites/ui/skeleton mage icon.png"

	base_max_health = 55
	max_health  = base_max_health
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	health_bar.visible = false
	damage_bar.max_value = max_health
	damage_bar.value = max_health
	damage_bar.visible = false
	
	bar_style.bg_color = Color("10bf00ff")
	bar_style.border_width_left = 2
	bar_style.border_width_top = 2
	bar_style.border_width_bottom = 2
	bar_style.border_color = Color(0.0, 0.0, 0.0, 1.0)
	health_bar.add_theme_stylebox_override(&"fill", bar_style)

	navigation_agent_2d.max_speed = speed
	move_target = global_position
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	state_machine = $WarriorStateMachine
	
	$VisionArea/CollisionShape2D.shape.radius = vision_range
	
	navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	$ClickArea.mouse_entered.connect(_on_click_area_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_click_area_mouse_exited)
	$VisionArea.body_entered.connect(_on_vision_area_body_entered)
	$VisionArea.body_exited.connect(_on_vision_area_body_exited)
	$Timers/NavigationTimer.timeout.connect(_on_navigation_timer_timeout)
	$Timers/AttackTimer.timeout.connect(_on_attack_timer_timeout)
	$Timers/HitFlashTimer.timeout.connect(_on_hit_flash_timer_timeout)
	$MovementPushArea.connect(&"body_entered", _on_movement_push_area_body_entered)
	$MovementPushArea.connect(&"body_exited", _on_movement_push_area_body_exited)
	
	#dodawanie shaderow to wszystkich spritow
	for child in $Sprite2D.get_children():
		child.use_parent_material = true
		for child_deeper in child.get_children():
			child_deeper.use_parent_material = true
	for raycast in raycast_array:
		raycast.set_collision_mask(0b100000)
	handle_skills()
	handle_starting_skills()
func _physics_process(_delta: float) -> void:
	#seek_enemies()
	if !dying:
		follow_player()
	#for unit in possible_targets:
		#if unit == null:
			#possible_targets.erase(unit)
#SKILLS ===============================================================================
func handle_skills():
	#dodaj do odpowiednich list umiejetnosci odblokowane
	for skill in Skills.unlocked_skills:
		for i in range(own_tags.size()):
			if skill.unit_tags.has(own_tags[i]):
				if skill.use_tags.has(Tags.UseTag.STAT_UP):
					skills_stat_up.append(skill)
				if skill.use_tags.has(Tags.UseTag.PASSIVE):
					skills_passive.append(skill)
				if skill.use_tags.has(Tags.UseTag.ON_HIT):
					skills_on_hit.append(skill)
				if skill.use_tags.has(Tags.UseTag.ON_DEATH):
					skills_on_death.append(skill)
				break
#NASTY STYLE updatujemy wszystkie skille mimo ze wiemy ktory sie zmienil, do poprawy
func handle_skill_update(skill):
	for i in range(own_tags.size()):
		if skill.unit_tags.has(own_tags[i]):
			if skill.use_tags.has(Tags.UseTag.STAT_UP):
				skills_stat_up.erase(skill)
				skills_stat_up.append(skill)
				skill.use(self)
			if skill.use_tags.has(Tags.UseTag.PASSIVE):
				skills_stat_up.erase(skill)
				skills_passive.append(skill)
				skill.use(self)
			if skill.use_tags.has(Tags.UseTag.ON_HIT):
				skills_on_hit.append(skill)
			if skill.use_tags.has(Tags.UseTag.ON_DEATH):
				skills_on_death.append(skill)
			break
func handle_starting_skills():
	for skill in skills_stat_up:
		skill.use(self)
	for skill in skills_passive:
		skill.use(self)
#INPUT ===============================================================================
func handle_inputs(event):
	if state_machine.state == state_machine.states.dying:
		return #jeśli jednostka umiera to nie możemy jej wydać rozkazów
	match event:
		&"left_click":
			if !state_machine.command_key == state_machine.command_keys.ATTACK_MOVE:
				return
			state_machine.command_key = state_machine.command_keys.NONE
			state_machine.command = state_machine.commands.ATTACK_MOVE
			move_target = get_global_mouse_position()
			state_machine.set_state(state_machine.states.moving)
		&"right_click":
			state_machine.command = state_machine.commands.MOVE
			state_machine.command_key = state_machine.command_keys.NONE
			move_target = get_global_mouse_position()
			state_machine.set_state(state_machine.states.moving)
		&"attack_move":
			state_machine.command_key = state_machine.command_keys.ATTACK_MOVE
		&"stop":
			state_machine.command = state_machine.commands.NONE
			state_machine.command_key = state_machine.command_keys.NONE
			state_machine.set_state(state_machine.states.idle)
		&"hold":
			state_machine.command = state_machine.commands.HOLD
			state_machine.command_key = state_machine.command_keys.NONE
			state_machine.set_state(state_machine.states.idle)

#MOVEMENT ===============================================================================
func _move_to_target(_delta,target_position):
	velocity = global_position.direction_to(target_position) * speed
	move_and_slide()
	
var unit_collision_push_array : Array = []
func push_units():
	for body in unit_collision_push_array:
		if !body.get_ref():
			continue
		if body.get_ref().state_machine.state != body.get_ref().state_machine.states.idle:
			continue
		if movement_order and body.get_ref().movement_order:
			if body.get_ref().movement_order.get_ref() == movement_order.get_ref():
				if self not in movement_order.get_ref().units_inside:
					continue
		if body.get_ref().state_machine.command == body.get_ref().state_machine.commands.HOLD:
			continue
			#ta liczba oznacza jak daleko ma sie odsunac odepchnieta jednostka
		if move_target:
			if angle_difference(global_position.angle_to_point(move_target), global_position.angle_to_point(body.get_ref().global_position)) < PI/2:
				#print("im pushin p")
				body.get_ref().move_target = body.get_ref().global_position + (global_position.direction_to(body.get_ref().global_position))
				body.get_ref().state_machine.set_state(body.get_ref().state_machine.states.moving)
				#body.get_ref().push_units()

func _on_movement_push_area_body_entered(body: Node2D) -> void:
	unit_collision_push_array.append(weakref(body))

func _on_movement_push_area_body_exited(body: Node2D) -> void:
	for unit in unit_collision_push_array:
		if unit.get_ref() == body:
			unit_collision_push_array.erase(unit)
var stuck_pathfining_timer = 0.2 #CZAS W SEKUNDACH
var epsilon = 10 #ILOSC PIXELI
func reset_stuck_pathfinding_timer():
	if unit_stuck_boolean:
		stuck_pathfining_timer = 0.1 #CZAS W SEKUNDACH
	else:
		stuck_pathfining_timer = 0.3
var unit_stuck_boolean : bool = false
var pathfinding_raycast
func move_to_target(delta,target_position): #CLOSE RANGE MOVEMENT
	#print("unit stuck bool:%s"%unit_stuck_boolean)
	stuck_pathfining_timer -= delta
	if stuck_pathfining_timer <= 0:
		#print("im checking if you're stuck")
		if last_position: #trzeba bedzie resetowac zeby nie pamietal last position z poprzedniego rozkazu
			if abs(last_position.x - global_position.x) < epsilon and abs(last_position.y - global_position.y) < epsilon:
				#print("im setting this stuff to true")
				unit_stuck_boolean = true
			else:
				pass
				#print("odleglosc byla wieksza niz epsilon")
		if unit_stuck_boolean:
			pathfinding_raycast = send_out_raycasts(target_position)
		last_position = global_position
		reset_stuck_pathfinding_timer()
	if unit_stuck_boolean:
		if pathfinding_raycast:
			target_position = global_position+pathfinding_raycast.target_position
		else:
			#print("im setting this stuff to false")
			unit_stuck_boolean = false
		#no i wysylamy raycasty
		#jesli najbardziej optymalny raycast jest wolny = mozesz isc prosto do celu
		#wiec bedzie podążał za punktami wyznaczonymi przez raycasty dopoki nie zwolni sobie optymalnego
	#jedna porcja a* zeby zrobic unified movement?
	var new_velocity
	if !get_slide_collision_count() and unstick_timer.is_stopped(): #tryb podstawowy
		navigation_agent_2d.target_position = target_position
		new_velocity = global_position.direction_to(target_position) * speed
		navigation_agent_2d.set_velocity(new_velocity)
	if get_slide_collision_count() and unstick_timer.is_stopped(): #wykrycie kolizji
		#print("i sense a collision")
		unstick_timer.start() # JEŚLI WYKRYJE KOLIZJE NA SEKUNDE DOSTAJE A* MOVEMENT
	if !unstick_timer.is_stopped(): #poruszanie sie z a* kiedy wykryje kolizje
		if can_navigate:
			calculate_new_path(target_position) #A* MOVEMENT
			new_velocity = global_position.direction_to(next_path_position) * speed
			navigation_agent_2d.set_velocity(new_velocity)
			can_navigate = false
			$Timers/NavigationTimer.start()
	move_and_slide()

func navigate_to_target(_delta,target_position): #A* MOVEMENT
	if can_navigate:
		calculate_new_path(target_position)
		can_navigate = false
		$Timers/NavigationTimer.start()
	var new_velocity = global_position.direction_to(next_path_position) * speed
	navigation_agent_2d.set_velocity(new_velocity)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func calculate_new_path(target_position):
	navigation_agent_2d.target_position = target_position
	next_path_position = navigation_agent_2d.get_next_path_position()

func _on_navigation_timer_timeout() -> void:
	can_navigate = true

func follow_player() -> void:
	if global_position.distance_to(Globals.player_position) > follow_distance_absolute:
		global_position = (Globals.player_position - global_position.direction_to(Globals.player_position) * 100)
		possible_targets = []
		possible_targets = $VisionArea.get_overlapping_bodies()
		attack_target = null
		move_target = null
		state_machine.state = state_machine.states.idle
		#state_machine.command = state_machine.commands.FOLLOW_PLAYER
		#move_target = (Globals.player_position - global_position.direction_to(Globals.player_position) * 100)
		#state_machine.state = state_machine.states.moving
	if state_machine.state == state_machine.states.idle: #powrót nawet podczas walki
		if global_position.distance_to(Globals.player_position) > follow_distance_idle:
			state_machine.command = state_machine.commands.FOLLOW_PLAYER
			move_target = (Globals.player_position - global_position.direction_to(Globals.player_position) * 100)
			state_machine.state = state_machine.states.moving
	elif state_machine.command == state_machine.commands.FOLLOW_PLAYER:
		move_target = (Globals.player_position - global_position.direction_to(Globals.player_position) * 100)

#COMBAT ===============================================================================
func hit(damage_taken, damage_source) -> bool:
	if health > 0:
		if damage_source not in status_effects_array:
			$Sprite2D.material.set_shader_parameter(&'progress',1)
			$Timers/HitFlashTimer.start()
			Audio.play_audio($sfx_receive_hit)
			$Particles/HitParticles.emitting = true
			took_damage.emit(damage_taken, self) #do wyswietlania damage numbers
	health_bar.visible = true
	damage_bar.visible = true
	health -= damage_taken
	health_bar.value = health
	
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", health, 0.5) 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	if health <= 0: #hp poniżej 0 - umieranie
		Globals.ui_unit_died.emit(self)
		dying = true
		health_bar.visible = false
		damage_bar.visible = false
		state_machine.call_deferred(&"set_state", state_machine.states.dying) #tu i niżej musimy zmienić na call_deferred(), i don't make the rules
		navigation_agent_2d.avoidance_enabled = false
		$CollisionShape2D.call_deferred(&"set_deferred", &"disabled", true) #disablujemy collision zeby przeciwnicy nie atakowali martwych unitów
		return false #returnuje false dla przeciwnika, który sprawdza czy jednostka wciąż żyje
	else:
		return true #jednostka ma ponad 0hp więc wciąż żyje
func forced_death():
		health = 0
		Globals.ui_unit_died.emit(self)
		dying = true
		health_bar.visible = false
		damage_bar.visible = false
		state_machine.call_deferred(&"set_state", state_machine.states.dying) #tu i niżej musimy zmienić na call_deferred(), i don't make the rules
		$CollisionShape2D.call_deferred(&"set_deferred", &"disabled", true) #disablujemy collision zeby przeciwnicy nie atakowali martwych unitów

func death():
	unit_died.emit(Tags.UnitTag.SKELETON_MAGE)
	for skill in skills_on_death:
		skill.use(self)

func heal(heal_amount):
	health += heal_amount
	health_bar.value = health
	if health >= max_health:
		health = max_health
		health_bar.visible = false
		damage_bar.visible = false
	else:
		var tween = create_tween()
		tween.tween_property(damage_bar, "value", health, 0.5) 
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
func attack():
	if !attack_target:
		return
	Audio.play_audio($sfx_projectile)
	if attack_target.get_ref(): #jeśli nasz cel wciąż istnieje:
		for skill in skills_on_hit:
			skill.use(self, attack_target.get_ref())
	else:
		state_machine.set_state(state_machine.states.idle) #cel zmarł - przejdź do stanu idle
func _attack():
	if attack_target: #jeśli nasz cel wciąż istnieje:
		if attack_target.get_ref().hit(damage, self): #wysyła hit do celu
			pass #jeśli cel zwrócił true - czyli żyje - kontynuuj atakowanie
		else:
			state_machine.set_state(state_machine.states.idle) #cel zmarł - przejdź do stanu idle

func seek_enemies():
	for unit in possible_targets:
		if unit == null:
			possible_targets.erase(unit)
	for enemy in get_tree().get_nodes_in_group(&"Unit"):
		if enemy not in get_tree().get_nodes_in_group(&"Allied"):
			if global_position.distance_to(enemy.global_position) > vision_range:
				if possible_targets.has(enemy):
					possible_targets.erase(enemy)
			else:
				if !possible_targets.has(enemy):
					possible_targets.append(enemy)

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"Unit"): #sprawdza czy jednostka, która weszła w vision range to valid target
		if not body.is_in_group(&"Allied"): #Sprawdza czy nie jest sojusznikiem
			possible_targets.append(body) #dodajemy target do listy

func _on_vision_area_body_exited(body: Node2D) -> void:
	if possible_targets.has(body): #jednostka z listy targetów wyszła z wizji
		possible_targets.erase(body)

#to jest funkcja do sortowania, jesli target a jest blizej targeta b to jest przesuwany blizej
#pozycji 0 w arrayu; a pozycja 0 w arrayu possible_target to najblizszy cel :D
func _compare_distance(target_a, target_b):
	if target_a and target_b:
		if global_position.distance_to(target_a.global_position) < global_position.distance_to(target_b.global_position):
			return true
		else:
			return false

func closest_enemy(): #sprawdza, który cel jest najbliżej
	if possible_targets.size() > 0:
		if possible_targets.size() > 1:
			possible_targets.sort_custom(_compare_distance) # <- to powyższy algorytm sortujący
		return possible_targets[0]
	else:
		return null

func attack_target_within_attack_range(): #sprawdź czy attack_target znajduje się w attack_range
	if attack_target.get_ref():
		if attack_target.get_ref().global_position.distance_to(global_position) < \
		attack_range:
			return attack_target.get_ref() #jeśli jest to go zwróć
		else:
			return null

func closest_enemy_within_attack_range():
	if closest_enemy() != null and closest_enemy().global_position.distance_to(global_position) < \
	attack_range:
		return closest_enemy()
	else:
		return null
#SELECTING ===============================================================================
#dodawanie i usuwanie z grupy Selected, wywoływane albo w scenie unit selector w levelu
#albo poprzez left click
func select() -> void:
	add_to_group(&"Selected")
	selected = true
	$Selected.visible = true

func deselect() -> void:
	if !state_machine.command_key == state_machine.command_keys.ATTACK_MOVE:
		remove_from_group(&"Selected")
		selected = false
		$Selected.visible = false

#do sprawdzania czy znajduje się w selection boxie w unit selectorze w scenie Level
func is_in_selection_box(select_box: Rect2):
	return select_box.has_point(global_position)

#Selectowanie jednostki left clickiem na nią
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if state_machine.command_key == state_machine.command_keys.ATTACK_MOVE:
			return #jesli chcemy zrobic attack move to nie selectujemy jednostki left clickowanej
		if event.is_released:
			#troche nasty style, potencjalnie do poprawy
			for unit in get_tree().get_nodes_in_group(&"Selected"):
				unit.deselect()
			select()
			Globals.units_selection_changed.emit(get_tree().get_nodes_in_group(&"Selected"))

#sprawdzamy czy myszka znajduje się w Area2D naszego ClickArea
func _on_click_area_mouse_entered() -> void:
	mouse_hovering = true
	#male testy do feedbacku dla gracza
	$Highlighted.visible = true
	Globals.add_overlapping_allies()

#sprawdzamy czy myszka znajduje się poza Area2D naszego ClickArea
func _on_click_area_mouse_exited() -> void:
	mouse_hovering = false
	#male testy do feedbacku dla gracza
	$Highlighted.visible = false
	Globals.remove_overlapping_allies()

#VISUALS ============================================================

func _on_hit_flash_timer_timeout() -> void:
	$Sprite2D.material.set_shader_parameter(&'progress',0)
