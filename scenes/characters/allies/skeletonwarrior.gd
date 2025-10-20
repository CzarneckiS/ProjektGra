extends UnitParent
 
#shitass funkcjonalnosc widzenia przeciwnikow, trzeba bedzie zrobic POWERFUL
#narazie rzucaja sie na pierwsza rzecz jaka zauwaza pozniej chce cool
#shitass dodawanie przeciwnikow do listy

var speed = 300
var moving: bool = false
var selected: bool = false
var enemy_seen: bool = false
var move_target = Vector2.ZERO
var stop_distance = 50

const move_treshold = 0.5
var last_position = Vector2.ZERO

@onready var state_machine = $WarriorStateMachine

# stop_distance to odleglosc od celu na ktorej jednostka sie zatrzyma
# mysle ze przy poruszaniu sie grupowym moznaby sie tym zabawic


func _ready() -> void:
	move_target = global_position

func _input(event: InputEvent) -> void:
	if selected and  state_machine.state !=  state_machine.states.dying:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_released():
				move_target = get_global_mouse_position()
				state_machine.set_state(state_machine.states.moving)


func move_to_target(delta,targ):
		#check out BOIDS (bird-oids)
	velocity = position.direction_to(targ) * speed
	if get_slide_collision_count() and $Timers/MoveTimer.is_stopped():
		$Timers/MoveTimer.start()
		last_position = global_position
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_and_slide()

func _on_vision_area_body_entered(_body: Node2D) -> void:
	#place holder, powinien znalezc cel i do niego isc i zaatakowac
	if enemy_seen == false:
		enemy_seen = true
		
func move_to(target):
	move_target = target
		
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

#INDYWIDUALNY SELECTING TROCHE SCUFFED - DO POPRAWY ! ! ! !
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released:
			select()
