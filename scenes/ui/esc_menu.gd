extends Control


@onready var button_continue: Button = $ButtonContinue
@onready var button_main_menu: Button = $ButtonMainMenu
@onready var button_exit: Button = $ButtonExit
@onready var button_options: Button = $ButtonOptions
@onready var button_restart: Button = $ButtonRestart

@onready var highlight_1: TextureRect = $ButtonContinue/Highlight
@onready var highlight_2: TextureRect = $ButtonMainMenu/Highlight
@onready var highlight_3: TextureRect = $ButtonExit/Highlight
@onready var highlight_4: TextureRect = $ButtonOptions/Highlight
@onready var highlight_5: TextureRect = $ButtonRestart/Highlight


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  
	
	button_continue.focus_mode = Control.FOCUS_NONE
	button_main_menu.focus_mode = Control.FOCUS_NONE
	button_exit.focus_mode = Control.FOCUS_NONE
	button_options.focus_mode = Control.FOCUS_NONE
	button_restart.focus_mode = Control.FOCUS_NONE
	
	_setup_hover(button_continue, highlight_1)
	_setup_hover(button_main_menu, highlight_2)
	_setup_hover(button_exit, highlight_3)
	_setup_hover(button_options, highlight_4)
	_setup_hover(button_restart, highlight_5)
		
		
	button_continue.pressed.connect(_on_button_continue_pressed)
	button_main_menu.pressed.connect(_on_button_main_menu_pressed)
	button_exit.pressed.connect(_on_button_exit_pressed)


func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("EscMenu"):
		get_tree().paused = false
		queue_free()


func _on_button_continue_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	queue_free()


func _on_button_main_menu_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_button_exit_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().quit()
