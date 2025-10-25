extends UnitParent
 
var speed = 300
var selected: bool = false
var move_target = Vector2.ZERO
var stop_distance = 20
const move_treshold = 0.5
var last_position = Vector2.ZERO

#combat
var damage = 1
#ZAWSZE ALE TO ZAWSZE PRZY ATTACK_TARGET UZYWAJCIE .get_ref()
var attack_target
var possible_targets = []
var attack_range = 80


@onready var state_machine = $WarriorStateMachine

# stop_distance to odleglosc od celu na ktorej jednostka sie zatrzyma
# mysle ze przy poruszaniu sie grupowym moznaby sie tym zabawic


func _ready() -> void:
	health = 30
	move_target = global_position

func _input(event: InputEvent) -> void:
	if selected and  state_machine.state !=  state_machine.states.dying:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_released():
				move_target = get_global_mouse_position()
				state_machine.set_state(state_machine.states.moving)

func hit(damage_taken) -> bool:
	health -= damage_taken
	if health <= 0:
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
	#przeszukuje wszystkie jednostki i patrzy czy jednostka NIE JEST w selectable
	#selectable to synonim allied jednostki
	if body.is_in_group("Unit"):
		if not body.is_in_group("Selectable"):
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

#func move_to(target):
	#move_target = target
		
func select() -> void:
	add_to_group("Selected")
	selected = true
	$Selected.visible = true
	
func deselect() -> void:
	remove_from_group("Selected")
	selected = false
	$Selected.visible = false
	
func is_in_selection_box(select_box: Rect2):
	return select_box.has_point(global_position)

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released:
			select()
