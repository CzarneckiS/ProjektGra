extends Node

# nie wiem czy jest sens rozbić na 2 różne sygnały dla hp/xp
signal ui_hp_update_requested
signal ui_exp_update_requested
signal lvl_up_menu_requested
signal units_selection_changed(new_units)
signal ui_unit_died(unit)

#sprawdzamy czy gracz widzial czaszke na start
var opening_shown = false

#statystyki głównej jednostki
var player : CharacterBody2D
var health : int = 200
var max_health : int = health
var player_position: Vector2

#exp i levelowanie
var xp_to_level : int = 300 #limit, ktory musimy dobic aby wbic lvl. placeholder value
var level : int = 1 #startowy lvl
var accumulated_xp : int = 0 #zebrany przez nas exp, startujemy bez expa

#podswietlanie kursora
var overlapping_enemies : int = 0 #sprawdzamy na ile jednostek najechaliśmy myszką
var overlapping_allies : int = 0
const neutral_cursor = preload("res://sprites/cursors/KursorRekaSmallNeutral.png")
const evil_cursor = preload("res://sprites/cursors/KursorRekaSmallEvil.png")
const allied_cursor = preload("res://sprites/cursors/KursorRekaSmallAllied.png")
const target_cursor = preload("res://sprites/cursors/KursorTarget.png")
var attack_move_input : bool = false

var wave_count = 0
signal wave_count_update()
signal boss_appeared()
signal boss_health_changed()
var boss_current_health
var boss_max_health

func reset_globals():
	health = 100
	max_health = health
	level = 1
	accumulated_xp = 0
	xp_to_level = 300
	ui_hp_update_requested.emit()
	lvl_up_menu_requested.emit()
	ui_exp_update_requested.emit()

func attack_move_input_pressed():
	Input.set_custom_mouse_cursor(target_cursor, Input.CURSOR_ARROW, Vector2(20,20))
	attack_move_input = true
func attack_move_input_ended():
	attack_move_input = false
	if overlapping_allies <= 0 and overlapping_enemies <= 0:
		Input.set_custom_mouse_cursor(neutral_cursor, Input.CURSOR_ARROW, Vector2(0,0))
	elif overlapping_enemies <= 0:
		Input.set_custom_mouse_cursor(allied_cursor, Input.CURSOR_ARROW, Vector2(0,0))
	elif overlapping_allies <= 0:
		Input.set_custom_mouse_cursor(evil_cursor, Input.CURSOR_ARROW, Vector2(0,0))
func add_overlapping_enemies(): #kiedy najedziemy myszka na przeciwnika to wywoluje tą funkcję
	overlapping_enemies += 1
	if attack_move_input:
		return
	Input.set_custom_mouse_cursor(evil_cursor)

func remove_overlapping_enemies(): #kiedy zjedziemy myszką z przeciwnika lub umrze to wywołuje
	if overlapping_enemies > 0:
		overlapping_enemies -= 1
	if attack_move_input:
		return
	if overlapping_enemies <= 0:
		if overlapping_allies <= 0:
			Input.set_custom_mouse_cursor(neutral_cursor) #neutralny kursor
		else:
			Input.set_custom_mouse_cursor(allied_cursor)

func add_overlapping_allies():
	overlapping_allies += 1
	if attack_move_input:
		return
	if overlapping_enemies <= 0:
		Input.set_custom_mouse_cursor(allied_cursor)

func remove_overlapping_allies():
	if overlapping_allies > 0:
		overlapping_allies -= 1
	if attack_move_input:
		return
	if overlapping_allies <= 0:
		if overlapping_enemies <= 0:
			Input.set_custom_mouse_cursor(neutral_cursor)
		else:
			Input.set_custom_mouse_cursor(evil_cursor)
#funkcja, ktora obsluguje to, co sie dzieje z postacia po lvl upie
func level_up():
	max_health += 20 #placeholder wartosc na zwiekszanie max hp
	health = max_health
	xp_to_level += 200 #placeholder wartosc na zwiekszanie limitu do uzyskania kolejnego lvla
	level += 1 #nie było tego, dodałem, nie wiem czy coś innego myśleliście
	
	ui_hp_update_requested.emit()
	lvl_up_menu_requested.emit()

func update_player_hp():
	ui_hp_update_requested.emit()
	if health <= 0:
		pass # play death()
	
#funkcja aktualizuje stan expa gracza, na razie jest wywoływana jedynie w fsm humanwarrior
func update_player_exp(xp_given): #funkcja przyjmuje wartosc expa, zaleznie od jednostki moze sie zmieniac
	accumulated_xp += xp_given #aktualizujemy expa
	while accumulated_xp >= xp_to_level: #dajemy pętle a nie zwykłego ifa bo teoretycznie możemy mieć uzbierane tyle expa, że moglibyśmy dostać kilka lvl upów
		accumulated_xp -= xp_to_level #jesli mamy wiecej expa niz trzeba to odejmujemy aktualny limit i zostawiamy reszte
		level_up() #wywolujemy lvl up tyle razy na ile mielismy expa
	
	ui_exp_update_requested.emit()
	
