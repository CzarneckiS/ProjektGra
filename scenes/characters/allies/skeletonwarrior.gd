extends UnitParent

var selected: bool = false

#movement
var speed = 300
var move_target = Vector2.ZERO
var stop_distance = 30 #jak daleko ma sie zatrzymywac od swojego celu (state == moving)
const move_treshold = 0.5 #temporary, bedzie wymienione przy pathfindingu
var last_position = Vector2.ZERO #temporary, bedzie wymienione przy pathfindingu

#combat
var damage = 20
var attack_target #ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UZYWAJCIE .get_ref()
var possible_targets = [] #jednostki ktore wejda w VisionArea
var attack_range = 80
var state_machine

func _ready() -> void:
	health = 100
	move_target = global_position
	state_machine = $WarriorStateMachine

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

func move_to_target(_delta,targ): #this shii temporary yo
		#check out BOIDS (bird-oids)
	velocity = global_position.direction_to(targ) * speed
	if get_slide_collision_count() and $Timers/MoveTimer.is_stopped():
		$Timers/MoveTimer.start()
		last_position = global_position
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_and_slide()

#COMBAT ===============================================================================
func hit(damage_taken) -> bool:
	health -= damage_taken #otrzymywanie obrażeń
	if health <= 0: #hp poniżej 0 - umieranie
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
		if not body.is_in_group("Selectable"): #Selectable to synonim allied jednostki
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
