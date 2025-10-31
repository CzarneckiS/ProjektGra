extends Node

#statystyki głównej jednostki
var health : int = 100
var max_health : int = health
var player_position: Vector2

#exp i levelowanie
var xp_to_level : int = 5 #limit, ktory musimy dobic aby wbic lvl. placeholder value
var level : int = 1 #startowy lvl
var accumulated_xp : int = 0 #zebrany przez nas exp, startujemy bez expa

#podswietlanie kursora
var overlapping_enemies = 0 #sprawdzamy na ile jednostek najechaliśmy myszką
var overlapping_allies = 0
var neutral_cursor = load("res://sprites/placeholders/KursorRekaSmallNeutral.png")
var evil_cursor = load("res://sprites/placeholders/KursorRekaSmallEvil.png")
var allied_cursor = load("res://sprites/placeholders/KursorRekaSmallAllied.png")

func add_overlapping_enemies(): #kiedy najedziemy myszka na przeciwnika to wywoluje tą funkcję
	overlapping_enemies += 1
	Input.set_custom_mouse_cursor(evil_cursor)

func remove_overlapping_enemies(): #kiedy zjedziemy myszką z przeciwnika lub umrze to wywołuje
	if overlapping_enemies > 0:
		overlapping_enemies -= 1
	if overlapping_enemies <= 0 and overlapping_allies <= 0: #jesli na nikogo nie wskazujemy kursorem
		Input.set_custom_mouse_cursor(neutral_cursor) #neutralny kursor

func add_overlapping_allies():
	overlapping_allies += 1
	if overlapping_enemies <= 0:
		Input.set_custom_mouse_cursor(allied_cursor)

func remove_overlapping_allies():
	if overlapping_allies > 0:
		overlapping_allies -= 1
	if overlapping_allies <= 0 and overlapping_enemies <= 0:
		Input.set_custom_mouse_cursor(neutral_cursor)
#funkcja, ktora obsluguje to, co sie dzieje z postacia po lvl upie
func level_up():
	max_health += 20 #placeholder wartosc na zwiekszanie max hp
	xp_to_level += 5 #placeholder wartosc na zwiekszanie limitu do uzyskania kolejnego lvla

func update_ui():
	#ta funkcja bedzie do updateowania duzego health bara na dole ekranu
	pass

#funkcja aktualizuje stan expa gracza, na razie jest wywoływana jedynie w fsm humanwarrior
func update_player_exp(xp_given): #funkcja przyjmuje wartosc expa, zaleznie od jednostki moze sie zmieniac
	accumulated_xp += xp_given #aktualizujemy expa
	while accumulated_xp >= xp_to_level: #dajemy pętle a nie zwykłego ifa bo teoretycznie możemy mieć uzbierane tyle expa, że moglibyśmy dostać kilka lvl upów
		accumulated_xp -= xp_to_level #jesli mamy wiecej expa niz trzeba to odejmujemy aktualny limit i zostawiamy reszte
		level_up() #wywolujemy lvl up tyle razy na ile mielismy expa
		#tutaj daj update_ui()
