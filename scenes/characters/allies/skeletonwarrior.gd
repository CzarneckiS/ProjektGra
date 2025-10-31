extends UnitParent

var selected: bool = false

#movement
var speed = 300
var move_target = Vector2.ZERO
var stop_distance = 30 #jak daleko ma sie zatrzymywac od swojego celu (state == moving)
const move_treshold = 0.5 #temporary, bedzie wymienione przy pathfindingu
var last_position = Vector2.ZERO #temporary, bedzie wymienione przy pathfindingu
var next_path_position
var can_navigate:bool = true

#combat
var damage = 20
var attack_target #ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UZYWAJCIE .get_ref()
var possible_targets = [] #jednostki ktore wejda w VisionArea
var attack_range = 100
var vision_range = 500

var mouse_hovering:bool = false

var state_machine
@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var unstick_timer: Timer = $Timers/UnstickTimer

func _ready() -> void:
	max_health  = 60
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
	health_bar.add_theme_stylebox_override("fill", bar_style)

	navigation_agent_2d.max_speed = speed
	move_target = global_position
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	state_machine = $WarriorStateMachine
	$VisionArea/CollisionShape2D.disabled = true
	
	navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	$ClickArea.mouse_entered.connect(_on_click_area_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_click_area_mouse_exited)
	$Timers/NavigationTimer.timeout.connect(_on_navigation_timer_timeout)
	
func _physics_process(_delta: float) -> void:
	seek_enemies()

#MOVEMENT ===============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if state_machine.state == state_machine.states.dying:
		return #jeśli jednostka umiera to nie możemy jej wydać rozkazów
	if !selected:
		return #sprawdzamy czy jednostka jest selectowana
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released(): #kiedy right clickujemy każemy jednostce iść do punktu na ziemi
			move_target = get_global_mouse_position()
			state_machine.set_state(state_machine.states.moving)
			print("skeletonwarrior chodzenie input")

func _move_to_target(_delta,target_position):
	velocity = global_position.direction_to(target_position) * speed
	move_and_slide()

func move_to_target(_delta,target_position): #CLOSE RANGE MOVEMENT
	if !get_slide_collision_count() and unstick_timer.is_stopped():
		navigation_agent_2d.target_position = target_position
		var new_velocity = global_position.direction_to(target_position) * speed
		navigation_agent_2d.set_velocity(new_velocity)
	if get_slide_collision_count() and unstick_timer.is_stopped():
		unstick_timer.start() # JEŚLI WYKRYJE KOLIZJE NA SEKUNDE DOSTAJE A* MOVEMENT
	if !unstick_timer.is_stopped():
		if can_navigate:
			calculate_new_path(target_position) #A* MOVEMENT
			var new_velocity = global_position.direction_to(next_path_position) * speed
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
	print(new_velocity)
	navigation_agent_2d.set_velocity(new_velocity)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func calculate_new_path(target_position):
	navigation_agent_2d.target_position = target_position
	next_path_position = navigation_agent_2d.get_next_path_position()

func _on_navigation_timer_timeout() -> void:
	can_navigate = true
#COMBAT ===============================================================================
func hit(damage_taken) -> bool:
	health_bar.visible = true
	damage_bar.visible = true
	
	health -= damage_taken
	health_bar.value = health
	
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", health, 0.5) 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	if health <= 0: #hp poniżej 0 - umieranie
		health_bar.visible = false
		damage_bar.visible = false
		state_machine.set_state(state_machine.states.dying)
		$CollisionShape2D.disabled = true #disablujemy collision zeby przeciwnicy nie atakowali martwych unitów
		return false #returnuje false dla przeciwnika, który sprawdza czy jednostka wciąż żyje
	else:
		return true #jednostka ma ponad 0hp więc wciąż żyje

func attack():
	if attack_target.get_ref(): #jeśli nasz cel wciąż istnieje:
		if attack_target.get_ref().hit(damage): #wysyła hit do celu
			pass #jeśli cel zwrócił true - czyli żyje - kontynuuj atakowanie
		else:
			state_machine.set_state(state_machine.states.idle) #cel zmarł - przejdź do stanu idle

func seek_enemies():
	for enemy in get_tree().get_nodes_in_group("Unit"):
		if enemy not in get_tree().get_nodes_in_group("Allied"):
			if global_position.distance_to(enemy.global_position) > vision_range:
				if possible_targets.has(enemy):
					possible_targets.erase(enemy)
			else:
				if !possible_targets.has(enemy):
					possible_targets.append(enemy)

#func _on_vision_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Unit"): #sprawdza czy jednostka, która weszła w vision range to valid target
		#if not body.is_in_group("Allied"): #Sprawdza czy nie jest sojusznikiem
			#possible_targets.append(body) #dodajemy target do listy
#
#func _on_vision_area_body_exited(body: Node2D) -> void:
	#if possible_targets.has(body): #jednostka z listy targetów wyszła z wizji
		#possible_targets.erase(body)

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
		possible_targets.sort_custom(_compare_distance) # <- to powyższy algorytm sortujący
		return possible_targets[0]
	else:
		return null

func attack_target_within_attack_range(): #sprawdź czy attack_target znajduje się w attack_range
	if attack_target.get_ref() and attack_target.get_ref().global_position.distance_to(global_position) < \
	attack_range:
		return attack_target.get_ref() #jeśli jest to go zwróć
	else:
		return null

#stara funkcja, ale niech zostanie
#func closest_enemy_within_attack_range():
	#if closest_enemy() != null and closest_enemy().global_position.distance_to(global_position) < \
	#attack_range:
		#return closest_enemy()
	#else:
		#return null
#SELECTING ===============================================================================
#dodawanie i usuwanie z grupy Selected, wywoływane albo w scenie unit selector w levelu
#albo poprzez left click
func select() -> void:
	add_to_group("Selected")
	selected = true
	$Selected.visible = true

func deselect() -> void:
	remove_from_group("Selected")
	selected = false
	$Selected.visible = false

#do sprawdzania czy znajduje się w selection boxie w unit selectorze w scenie Level
func is_in_selection_box(select_box: Rect2):
	return select_box.has_point(global_position)

#Selectowanie jednostki left clickiem na nią
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released:
			select()

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
