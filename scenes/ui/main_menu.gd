extends Control

@onready var button_start: Button = $ButtonStart
@onready var button_achievments: Button = $ButtonAchievments
@onready var button_options: Button = $ButtonOptions
@onready var button_exit: Button = $ButtonExit

@onready var highlight_1: TextureRect = $ButtonStart/Highlight
@onready var highlight_2: TextureRect = $ButtonAchievments/Highlight
@onready var highlight_3: TextureRect = $ButtonOptions/Highlight
@onready var highlight_4: TextureRect = $ButtonExit/Highlight

var screen_starting_pos
var parallax_speed = 5

func _ready() -> void:
	#opening z czaszka na start
	if !Globals.opening_shown:
		$BlackScreen.visible = true
		await get_tree().create_timer(1).timeout
		var tween1 = create_tween()
		tween1.tween_property($Skull,"modulate:a",1,0.5)
		await get_tree().create_timer(1).timeout
		var tween2 = create_tween()
		tween2.tween_property($Skull,"modulate:a",0,0.5)
		tween2.tween_property($BlackScreen,"modulate:a",0,0.5)
		Globals.opening_shown = true
	else:
		$BlackScreen.visible = false

	$ButtonStart.pressed.connect(_on_button_start_pressed)
	$ButtonExit.pressed.connect(_on_button_exit_pressed)
	$ButtonAchievments.pressed.connect(_on_button_achievements_pressed)
	
	button_start.focus_mode = Control.FOCUS_NONE
	button_achievments.focus_mode = Control.FOCUS_NONE
	button_options.focus_mode = Control.FOCUS_NONE
	button_exit.focus_mode = Control.FOCUS_NONE
	
	screen_starting_pos = $Clouds.global_position
	
	#_setup_hover(button_start, highlight_1)
	#_setup_hover(button_achievments, highlight_2)
	#_setup_hover(button_options, highlight_3)
	#_setup_hover(button_exit, highlight_4)

func _process(delta: float) -> void:
	if screen_starting_pos:
		var target_position: Vector2 = screen_starting_pos - (get_global_mouse_position()-get_viewport_rect().size)*0.01
		var castle_target_position: Vector2 = screen_starting_pos - (get_global_mouse_position()-get_viewport_rect().size)*0.003
		$Girl.global_position = $Girl.global_position.lerp(target_position, delta * parallax_speed)
		$Skellington.global_position = $Skellington.global_position.lerp(target_position, delta * parallax_speed)
		$Castle.global_position = $Castle.global_position.lerp(castle_target_position, delta * parallax_speed)
func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)

	
func _on_button_start_pressed() -> void:
	start_new_game()


func _on_button_options_pressed() -> void:
	#get_tree().change_scene_to_file("ZAMIENIĆ NA LOKALIZACJE")
	pass
	
func _on_button_achievements_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/achievements.tscn")

func _on_button_exit_pressed() -> void:
	get_tree().quit()

func start_new_game():
	Globals.reset_globals()
	Skills.reset_unlocked_skills()
	Achievements.skill_unlock_handler.handle_unlocked_skills()
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
