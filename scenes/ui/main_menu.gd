extends Control

@onready var button_start: Button = $ButtonStart
@onready var button_achievments: Button = $ButtonAchievments
@onready var button_options: Button = $ButtonOptions
@onready var button_exit: Button = $ButtonExit

@onready var highlight_1: TextureRect = $ButtonStart/Highlight
@onready var highlight_2: TextureRect = $ButtonAchievments/Highlight
@onready var highlight_3: TextureRect = $ButtonOptions/Highlight
@onready var highlight_4: TextureRect = $ButtonExit/Highlight

func _ready() -> void:
	$ButtonStart.pressed.connect(_on_button_start_pressed)
	$ButtonExit.pressed.connect(_on_button_exit_pressed)
	$ButtonAchievments.pressed.connect(_on_button_achievements_pressed)
	
	button_start.focus_mode = Control.FOCUS_NONE
	button_achievments.focus_mode = Control.FOCUS_NONE
	button_options.focus_mode = Control.FOCUS_NONE
	button_exit.focus_mode = Control.FOCUS_NONE
	
	_setup_hover(button_start, highlight_1)
	_setup_hover(button_achievments, highlight_2)
	_setup_hover(button_options, highlight_3)
	_setup_hover(button_exit, highlight_4)

	
func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)

	
func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")


func _on_button_options_pressed() -> void:
	#get_tree().change_scene_to_file("ZAMIENIĆ NA LOKALIZACJE")
	pass
	
func _on_button_achievements_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/achievements.tscn")

func _on_button_exit_pressed() -> void:
	get_tree().quit()
