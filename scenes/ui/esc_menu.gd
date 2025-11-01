extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  

	$VBoxContainer/ButtonContinue.pressed.connect(_on_button_continue_pressed)
	$VBoxContainer/ButtonMainMenu.pressed.connect(_on_button_main_menu_pressed)
	$VBoxContainer/ButtonExit.pressed.connect(_on_button_exit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("EscMenu"):
		get_tree().paused = false
		queue_free() 
		
func _on_button_continue_pressed() -> void:
	get_tree().paused = false 
	queue_free()               


func _on_button_main_menu_pressed() -> void:
	get_tree().paused = true
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_button_exit_pressed() -> void:
	get_tree().quit()
