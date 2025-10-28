extends Node
class_name StateMachine

var state = null
var previous_state = null
#no fucking clue czemu to jest dictionary a nie array zwykly
var states = {}

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	if state != null:
		_state_logic(delta)
		_get_transition(delta)

#TU BEZ PODLOGI CHYBA BO KORZYSTAMY W JEGO DZIECIACH Z DELTY ALE NIE WIEM CZY MUSIMY W NICH KORZYSTAC
#i guess w przyszlosci sie zobaczy, tak po prostu bylo w tutorialu
func _state_logic(delta):
	pass

func _get_transition(_delta):
	pass

func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)
		
func _exit_state(_previous_state, _new_state):
	pass
	
func _enter_state(_new_state, _previous_state):
	pass

func add_state(state_name):
	states[state_name] = states.size()
