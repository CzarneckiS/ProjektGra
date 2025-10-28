extends Control



func _ready() -> void:
	#connectowanie sygnałów z przycisków
	$VBoxContainer/ButtonContinue.pressed.connect(_on_button_continue_pressed)
	$VBoxContainer/ButtonMainMenu.pressed.connect(_on_button_main_menu_pressed)
	$VBoxContainer/ButtonExit.pressed.connect(_on_button_exit_pressed)


#przycisk esc kiedy już znajdujemy się w escape menu -> powrót do gry
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("EscMenu"):
		get_tree().change_scene_to_file("res://scenes/levels/level.tscn")

#przycisk continue -> powrót do gry
func _on_button_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
	
#przycisk main menu -> przejście do menu głównego
func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	
#przycisk exit -> wyjście z gry
func _on_button_exit_pressed() -> void:
	get_tree().quit()
