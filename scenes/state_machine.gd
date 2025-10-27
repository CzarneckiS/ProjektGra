extends Node
class_name StateMachine

#Mała definicja dla przypomnienia, później sie wywali
#State - stan, w którym znajduje się jednostka (np przemieszcza się, atakuje coś)
#State Machine to system, który przypisuje jednostkom odpowiedni state,
#i sprawia, że jednostki wykonują rozkazy przypisane do danego state
#state logic to zestaw rozkazów, które im wydajemy w każdym physics frame (np idź do celu)
#get transition to zbiór warunków, które sprawdzają kiedy jednostka ma zmienić aktualny state
#na przykład jeśli jesteś moving i dojdziesz do celu przejdź w state idle

var state = null #aktualny stan
var previous_state = null #Tymczasowo niezbyt ważne ale niech zostanie
var states = {} #nasz dictionary wszystkich dostępnych stanów

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	if state != null:
		_state_logic(delta) #Co jednostka ma robić
		_get_transition(delta) #Warunki przejścia do nowego stanu

func _state_logic(_delta):
	pass

func _get_transition(_delta):
	pass

#Zmień aktualny state w inny
func set_state(new_state):
	previous_state = state #Tymczasowo niezbyt ważne ale niech zostanie
	state = new_state #Przejdź w nowy stan
	
	if previous_state != null:#Tymczasowo niezbyt ważne ale niech zostanie
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func _exit_state(_previous_state, _new_state):
	pass
func _enter_state(_new_state, _previous_state):
	pass

func add_state(state_name): #dodawanie stateów do listy
	states[state_name] = states.size()
