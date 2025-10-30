extends UnitParent

#thought - nie robic tak, ze mobki ida PROSTO na gracza od razu
#tylko dla coolnosci zrobic tak ze ida kawalek w mniej wiecej kierunku gracza
#i sie zatrzymuja i nazwac ten stan wandering dla realizmu????? idk idk

#exp ktory daje warrior, wykorzystywany przekazywany do fsm w dying state
const warrior_exp = 15

#movement
var speed = 300
var move_target = Vector2.ZERO
var stop_distance = 30 #jak daleko ma sie zatrzymywac od swojego celu (state == moving)
const move_treshold = 0.5 #temporary, bedzie wymienione przy pathfindingu
var last_position = Vector2.ZERO #temporary, bedzie wymienione przy pathfindingu
var wait_frames = 5 #ustawiac na 5 kiedy narzucamy jednostce zmiane celu (engaging)??
var next_path_position

#combat
var damage = 10
var attack_target #ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UŻYWAJCIE .get_ref()
var possible_targets = [] #jednostki ktore wejda w VisionArea
var attack_range = 100

#clicking
signal target_clicked(target_node: Node) #sygnał, który będzie wysyłany do naszych jednostek
# aby weszły w engaging state jeśli klikniemy na wroga
var mouse_hovering : bool = false #sluzy do sprawdzania czy myszka jest w clickarea humanwarriora

@onready var state_machine = $HumWarriorStateMachine
@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	max_health  = 60
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
	health_bar.add_theme_stylebox_override("fill", bar_style)
	
	move_target = Globals.player_position
	navigation_agent_2d.max_speed = 300 #to jest prawdziwy speed teraz
	$CollisionShape2D.disabled = true
	
	navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	$ClickArea.mouse_entered.connect(_on_click_area_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_click_area_mouse_exited)

#MOVEMENT ===============================================================================
func move_to_target(delta,target_position): #DO TESTÓW
	velocity = global_position.direction_to(target_position) * speed
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	global_position += velocity * delta
func _move_to_target(_delta,target_position): #this shii temporary yo
		#check out BOIDS (bird-oids)
	if wait_frames >= 5: #czeka jednego frame'a przed kalkulacją ścieżki
		calculate_new_path(target_position)
		#if get_slide_collision_count() and $Timers/MoveTimer.is_stopped():
			#$Timers/MoveTimer.start()
			#last_position = global_position
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		wait_frames = 0
	else:
		wait_frames += 1
	var new_velocity = global_position.direction_to(next_path_position) * speed
	navigation_agent_2d.set_velocity(new_velocity)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func calculate_new_path(target_position):
	navigation_agent_2d.target_position = target_position
	next_path_position = navigation_agent_2d.get_next_path_position()


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

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Unit"): #sprawdza czy jednostka, która weszła w vision range to valid target
		if body.is_in_group("Allied"): #Sprawdza czy jest to sojusznik głownego gracza
			possible_targets.append(body) #dodajemy target do listy

func _on_vision_area_body_exited(body: Node2D) -> void:
	if possible_targets.has(body): #jednostka z listy targetów wyszła z wizji
		possible_targets.erase(body)

#to jest funkcja do sortowania, jesli target a jest blizej targeta b to jest przesuwany blizej
#pozycji 0 w arrayu; a pozycja 0 w arrayu possible_target to najblizszy cel :D
func _compare_distance(target_a, target_b):
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

func closest_enemy_within_attack_range(): #sprawdza czy najbliższy przeciwnik jest w zasięgu ataku
	if closest_enemy() != null and closest_enemy().global_position.distance_to(global_position) < attack_range:
		return closest_enemy()
	else:
		return null

#TARGETOWANIE POPRZEZ KLIKANIE MYSZKĄ ==========================================================
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_released(): #sprawdzamy czy puściliśmy prawy przycisk myszy
			return
		if state_machine.state == state_machine.states.dying: #sprawdzamy czy przeciwnik nie umiera
			return
		if !mouse_hovering: #sprawdzamy czy myszka znajduje sie w ClickArea humanwarriora
			return
		if get_tree().get_nodes_in_group("Selected"): #jesli zselectowaliśmy jakąś allied jednostke
			target_clicked.emit(self) #emitujemy sygnal, ze cel zostal klikniety
			$AnimationPlayerSelected.play("clicked_enemy") #odgrywamy animacje zaznaczenia humanwarriora
			get_viewport().set_input_as_handled()
			print("humanwarrior byl klikniety") #debug

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
