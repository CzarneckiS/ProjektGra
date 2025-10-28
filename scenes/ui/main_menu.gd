extends Control


func _ready() -> void:
	$VBoxContainer/ButtonStart.pressed.connect(_on_start_start_pressed)
	$VBoxContainer/ButtonExit.pressed.connect(_on_button_exit_pressed)

func _on_start_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")


func _on_button_options_pressed() -> void:
	#get_tree().change_scene_to_file("ZAMIENIĆ NA LOKALIZACJE")
	pass

func _on_button_exit_pressed() -> void:
	get_tree().quit()
