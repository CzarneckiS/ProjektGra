extends UnitParent
class_name HumanWarrior

var melee_attack_vfx = preload("res://vfx/melee_attack_slash/melee_attack_slash_vfx.tres")

var skills_stat_up : Array = []
var skills_passive : Array = []
var skills_on_hit : Array = [melee_attack_vfx]
var skills_on_death : Array = []
var own_tags : PackedInt32Array = []
#exp ktory daje warrior, wykorzystywany przekazywany do fsm w dying state
const experience_value = 15

#movement
var speed = 300
var stop_distance = 30 #jak daleko ma sie zatrzymywac od swojego celu (state == moving)
const move_treshold = 0.5 #temporary, bedzie wymienione przy pathfindingu
var last_position
var next_path_position
var can_navigate:bool = true

#combat
var damage = 10
var attack_target #ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UŻYWAJCIE .get_ref()
var possible_targets = [] #jednostki ktore wejda w VisionArea
var attack_range = 100
var vision_range = 300
var dying : bool = false
var attack_time = 0.3 #czas pomiędzy atakami
#clicking
signal target_clicked(target_node: Node) #sygnał, który będzie wysyłany do naszych jednostek
# aby weszły w engaging state jeśli klikniemy na wroga
var mouse_hovering : bool = false #sluzy do sprawdzania czy myszka jest w clickarea humanwarriora

@onready var state_machine = $HumWarriorStateMachine
@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var unstick_timer: Timer = $Timers/UnstickTimer

#func apply_knockback(attack_position: Vector2, force: float):
	#var knockback_direction: Vector2 = (global_position - attack_position).normalized()
	#knockback_velocity = knockback_direction * force
	#navigation_agent_2d.set_velocity(Vector2.ZERO)
	#state_machine.set_state(state_machine.states.knockback)
	
func _ready() -> void:
	base_max_health = 60
	max_health  = base_max_health
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	health_bar.visible = false
	damage_bar.max_value = max_health
	damage_bar.value = max_health
	damage_bar.visible = false
	
	bar_style.bg_color = Color("ef595cff")
	bar_style.border_width_left = 2
	bar_style.border_width_top = 2
	bar_style.border_width_bottom = 2
	bar_style.border_color = Color(0.0, 0.0, 0.0, 1.0)
	health_bar.add_theme_stylebox_override(&"fill", bar_style)
	
	move_target = Globals.player_position
	navigation_agent_2d.max_speed = speed
	navigation_agent_2d.radius = 20 #im wieksza liczba tym bardziej unika kolizji
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	$VisionArea/CollisionShape2D.shape.radius = vision_range
	$Timers/AttackTimer.wait_time = attack_time
	
	navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	$ClickArea.mouse_entered.connect(_on_click_area_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_click_area_mouse_exited)
	$VisionArea.body_entered.connect(_on_vision_area_body_entered)
	$VisionArea.body_exited.connect(_on_vision_area_body_exited)
	$Timers/NavigationTimer.timeout.connect(_on_navigation_timer_timeout)
	$Timers/AttackTimer.timeout.connect(_on_attack_timer_timeout)
	$Timers/HitFlashTimer.timeout.connect(_on_hit_flash_timer_timeout)
	$Particles/HitParticles.modulate = Color(1.0, 0.0, 0.0, 1.0)
	#dodawanie shaderow to wszystkich spritow
	for child in $Sprite2D.get_children():
		child.use_parent_material = true
	for raycast in raycast_array:
		raycast.set_collision_mask(0b100)
#VISUALSY ===============================================================================
func start_hit_flash(damage_source):
	var original_color = Color.WHITE
	var hit_color: Color = Color.WHITE * 8.0
	var flash_tween = create_tween()
	
	if damage_source is FireballSpell:
		hit_color = Color("39db9dff") * 5.0
	if damage_source is ThunderboltSpell:
		hit_color = Color("375cedff") * 3.0
	if damage_source is IceblockSpell:
		hit_color = Color("837cffff") * 3.0
	flash_tween.tween_property($Sprite2D, "modulate", hit_color, 0.05)
	flash_tween.tween_property($Sprite2D, "modulate", original_color, 0.2)
	
	flash_tween.set_ease(Tween.EASE_OUT)


#MOVEMENT ===============================================================================
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
				print("odleglosc byla wieksza niz epsilon")
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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func calculate_new_path(target_position):
	navigation_agent_2d.target_position = target_position
	next_path_position = navigation_agent_2d.get_next_path_position()

func _on_navigation_timer_timeout() -> void:
	can_navigate = true

#COMBAT ===============================================================================
func hit(damage_taken, damage_source) -> bool:
	if health > 0:
		if damage_source not in status_effects_array:
			$Sprite2D.material.set_shader_parameter(&'progress',1)
			$Timers/HitFlashTimer.start()
			$Particles/HitParticles.emitting = true
			took_damage.emit(damage_taken, self) #do wyswietlania damage numbers
	health_bar.visible = true
	damage_bar.visible = true
	
	health -= damage_taken
	health_bar.value = health
	
	if damage_source is Area2D:
		start_hit_flash(damage_source)
	
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", health, 0.5) 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	if health <= 0: #hp poniżej 0 - umieranie
		dying = true
		health_bar.visible = false
		damage_bar.visible = false
		state_machine.call_deferred(&"set_state", state_machine.states.dying) #zmiana na call_deferred bo przy spellach powodowało, że debugger nie był happy (przez sygnał _on_body_entered w fireball gdzie wywołujemy hit())
		navigation_agent_2d.avoidance_enabled = false
		$CollisionShape2D.call_deferred(&"set_deferred", &"disabled", true) #disablujemy collision zeby przeciwnicy nie atakowali martwych unitów. Zmiana na call_deferred by debugger był happy, patrz wyżej.
		return false #returnuje false dla przeciwnika, który sprawdza czy jednostka wciąż żyje
	else:
		return true #jednostka ma ponad 0hp więc wciąż żyje

func death():
	unit_died.emit(Tags.UnitTag.HUMAN_WARRIOR)
	for skill in skills_on_death:
		skill.use(self)

func attack():
	$sfx_attack.play()
	if attack_target.get_ref(): #jeśli nasz cel wciąż istnieje:
		#check czy cel nie odszedl za daleko
		if global_position.distance_to(attack_target.get_ref().global_position) < 300:
			attack_target.get_ref().hit(damage, self)
		for skill in skills_on_hit:
			skill.use(self, attack_target.get_ref())
	else:
		state_machine.set_state(state_machine.states.idle) #cel zmarł - przejdź do stanu idle
	can_attack = false
	$Timers/AttackTimer.start()

func seek_enemies():
	for unit in possible_targets:
		if unit == null:
			possible_targets.erase(unit)
	for enemy in get_tree().get_nodes_in_group(&"Allied"):
		if global_position.distance_to(enemy.global_position) > vision_range:
			if possible_targets.has(enemy):
				possible_targets.erase(enemy)
		else:
			if !possible_targets.has(enemy):
				possible_targets.append(enemy)
				

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"Unit"): #sprawdza czy jednostka, która weszła w vision range to valid target
		if body.is_in_group(&"Allied"): #Sprawdza czy jest to sojusznik głownego gracza
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

func closest_enemy_within_attack_range(): #sprawdza czy najbliższy przeciwnik jest w zasięgu ataku
	if closest_enemy() != null and closest_enemy().global_position.distance_to(global_position) < attack_range:
		return closest_enemy()
	else:
		return null

#TARGETOWANIE POPRZEZ KLIKANIE MYSZKĄ ==========================================================
func _input(event: InputEvent) -> void:
	if state_machine.state == state_machine.states.dying: #sprawdzamy czy przeciwnik nie umiera
		return
	if !mouse_hovering: #sprawdzamy czy myszka znajduje sie w ClickArea humanwarriora
		return
	if !event.is_released(): #sprawdzamy czy puściliśmy przycisk myszy
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if get_tree().get_nodes_in_group(&"Selected"): #jesli zselectowaliśmy jakąś allied jednostke
			target_clicked.emit(self) #emitujemy sygnal, ze cel zostal klikniety
			$AnimationPlayerSelected.play(&"clicked_enemy") #odgrywamy animacje zaznaczenia humanwarriora
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Globals.attack_move_input:
			return
		if get_tree().get_nodes_in_group(&"Selected"):
			target_clicked.emit(self)
			$AnimationPlayerSelected.play(&"clicked_enemy")

#sprawdzamy czy myszka znajduje się w Area2D naszego ClickArea
func _on_click_area_mouse_entered() -> void:
	mouse_hovering = true
	#male testy do feedbacku dla gracza
	$Highlighted.visible = true
	Globals.add_overlapping_enemies()

#sprawdzamy czy myszka znajduje się poza Area2D naszego ClickArea
func _on_click_area_mouse_exited() -> void:
	mouse_hovering = false
	#male testy do feedbacku dla gracza
	$Highlighted.visible = false
	Globals.remove_overlapping_enemies()

#VISUALS ============================================================

func _on_hit_flash_timer_timeout() -> void:
	$Sprite2D.material.set_shader_parameter(&'progress',0)
