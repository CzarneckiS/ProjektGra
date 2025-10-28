extends UnitParent

#ustawic na false :*
#thought - nie robic tak, ze mobki ida PROSTO na gracza od razu
#tylko dla coolnosci zrobic tak ze ida kawalek w mniej wiecej kierunku gracza
#i sie zatrzymuja i nazwac ten stan wandering dla realizmu????? idk idk

var speed = 300
var move_target = Vector2.ZERO
var stop_distance = 20
const move_treshold = 0.5
var last_position = Vector2.ZERO

#combat
var damage = 10
#ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UZYWAJCIE .get_ref()
var attack_target
var possible_targets = []
var attack_range = 80

#clicking
signal target_clicked(target_node: Node) #sygnał, który będzie wysyłany do naszych jednostek aby weszły w engaging state jeśli klikniemy na wroga
var mouse_hovering : bool = false #sluzy do sprawdzania czy myszka jest w clickarea humanwarriora

@onready var state_machine = $HumWarriorStateMachine
@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar

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
	#łączymy sygnały, że myszka jest w naszym clickarea
	$ClickArea.mouse_entered.connect(_on_click_area_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_click_area_mouse_exited)

func _process(_delta: float) -> void:
	pass
	#ten process jest do debugowania

func hit(damage_taken) -> bool:
	health_bar.visible = true
	damage_bar.visible = true
	
	health -= damage_taken
	health_bar.value = health
	
	var tween = create_tween()
	tween.tween_property(damage_bar, "value", health, 0.5) 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	
	if health <= 0:
		health_bar.visible = false
		damage_bar.visible = false
		state_machine.set_state(state_machine.states.dying)
		$CollisionShape2D.disabled = true
		return false
	else:
		return true

func attack():
	if attack_target.get_ref():
		if attack_target.get_ref().hit(damage):
			pass
		else:
			state_machine.set_state(state_machine.states.idle)

func move_to_target(_delta,targ):
		#check out BOIDS (bird-oids)
	velocity = global_position.direction_to(targ) * speed
	if get_slide_collision_count() and $Timers/MoveTimer.is_stopped():
		$Timers/MoveTimer.start()
		last_position = global_position
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_and_slide()

func _on_vision_area_body_entered(body: Node2D) -> void:
	#przeszukuje wszystkie jednostki i patrzy czy jednostka JEST w selectable
	#selectable to synonim allied jednostki
	if body.is_in_group("Unit"):
		if body.is_in_group("Selectable"):
			possible_targets.append(body)
			
func _on_vision_area_body_exited(body: Node2D) -> void:
	if possible_targets.has(body):
		possible_targets.erase(body)
		
#to jest funkcja do sortowania, jesli target a jest blizej targeta b to jest przesuwany blizej
#pozycji 0 w arrayu; a pozycja 0 w arrayu possible_target to najblizszy cel :D
func _compare_distance(target_a, target_b):
	if global_position.distance_to(target_a.global_position) < global_position.distance_to(target_b.global_position):
		return true
	else:
		return false

func closest_enemy():
	if possible_targets.size() > 0:
		possible_targets.sort_custom(_compare_distance)
		return possible_targets[0]
	else:
		return null

func closest_enemy_within_attack_range():
	if closest_enemy() != null and closest_enemy().global_position.distance_to(global_position) < attack_range:
		return closest_enemy()
	else:
		return null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released():
			if mouse_hovering: #jesli myszka znajduje sie w ClickArea humanwarriora
				if get_tree().get_nodes_in_group("Selected"): #jesli humanwarrior jest selected
					target_clicked.emit(self) #emitujemy sygnal, ze cel zostal klikniety
					$AnimationPlayerSelected.play("clicked_enemy") #odgrywamy animacje zaznaczenia humanwarriora
					get_viewport().set_input_as_handled()
					print("humanwarrior byl klikniety") #debug

#obsługa sygnału na rightclick, idzie do skeletonwarriora
#func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#if event.is_released():
			#target_clicked.emit(self)
			#get_viewport().set_input_as_handled()

#sprawdzamy czy myszka znajduje się w Area2D naszego ClickArea
func _on_click_area_mouse_entered() -> void:
	mouse_hovering = true

#sprawdzamy czy myszka znajduje się poza Area2D naszego ClickArea
func _on_click_area_mouse_exited() -> void:
	mouse_hovering = false
