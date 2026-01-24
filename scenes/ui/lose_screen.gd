extends Control

func _ready() -> void:
	_setup_hover($MainMenu, $MainMenu/Highlight)
	_setup_hover($Exit, $Exit/Highlight)
	
	$MainMenu.pressed.connect(_on_button_main_menu_pressed)
	$Exit.pressed.connect(_on_button_exit_pressed)
	
	$MainMenu.focus_mode = Control.FOCUS_NONE
	$Exit.focus_mode = Control.FOCUS_NONE
	
	var tween2 = create_tween()
	tween2.tween_property($BlackScreen,"modulate:a",1,0.5)
	await get_tree().create_timer(1).timeout
	var tween1 = create_tween()
	tween1.tween_property($Skull,"modulate:a",1,0.5)
	await get_tree().create_timer(1).timeout
	var tween3 = create_tween()
	tween3.tween_property($Skull, "position:y", $Skull.position.y-220,0.3)
	tween3.set_ease(Tween.EASE_OUT)
	await tween3.finished
	var tween4 = create_tween()
	tween4.set_parallel(true)
	tween4.tween_property($MainMenu,"modulate:a",1,0.2)
	tween4.tween_property($Exit,"modulate:a",1,0.2)
	tween4.tween_property($LoseTextHolder,"modulate:a",1,0.2)
	$MainMenu.disabled = false
	$Exit.disabled = false
	$lose_sfx.play()

func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)

func _on_button_main_menu_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file","res://scenes/ui/main_menu.tscn")
	

func _on_button_exit_pressed() -> void:
	$menu_click.play()
	get_tree().call_deferred("quit")
	
