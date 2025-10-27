extends Node

#statystyki głównej jednostki
var health = 100
var max_health 
var player_position: Vector2

#exp i levelowanie
var xp = 0
var max_xp
var level

#podswietlanie kursora
var overlapping_units = 0 #sprawdzamy na ile jednostek najechaliśmy myszką
var neutral_cursor = load("res://sprites/placeholders/KursorRekaSmallNeutral.png")
var evil_cursor = load("res://sprites/placeholders/KursorRekaSmallEvil.png")

func add_overlapping_units(): #kiedy najedziemy myszka na przeciwnika to wywoluje tą funkcję
	overlapping_units += 1
	Input.set_custom_mouse_cursor(evil_cursor)

func remove_overlapping_units(): #kiedy zjedziemy myszką z przeciwnika lub umrze to wywołuje
	if overlapping_units > 0:
		overlapping_units -= 1
	if overlapping_units <= 0:
		Input.set_custom_mouse_cursor(neutral_cursor)

#mr oskar jak cos to sa STARE placeholdery z tym level up, rob tutaj jak uwazasz
func level_up():
	max_health += 20
	xp -= max_xp #nadwyzka expa przechodzi dalej
	max_xp += 100 #nw czy obchodzi nas ladne skalowanie sie expa :b 

func update_ui():
	#ta funkcja bedzie do updateowania duzego health bara na dole ekranu
	pass
