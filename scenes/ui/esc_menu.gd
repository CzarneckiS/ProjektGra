extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/ButtonContinue.pressed.connect(_on_button_continue_pressed)
	$VBoxContainer/ButtonMainMenu.pressed.connect(_on_button_main_menu_pressed)
	$VBoxContainer/ButtonExit.pressed.connect(_on_button_exit_pressed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("EscMenu"):
		get_tree().change_scene_to_file("res://scenes/levels/level.tscn")



func _on_button_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
	

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	

func _on_button_exit_pressed() -> void:
	get_tree().quit()
