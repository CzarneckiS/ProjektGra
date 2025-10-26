extends Node2D

@onready var move_cursor = $MoveCursor

# EnemySpawnFollow bierzemy jako unique name
func spawn_enemy():
	var new_enemy = preload("res://scenes/characters/enemies/humanwarrior.tscn").instantiate()
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	new_enemy.global_position = %EnemySpawnFollow.global_position
	#new_enemy.connect("target_clicked", _on_target_clicked)
	add_child(new_enemy)

func _ready():
	#musimy dla kazdej instancji warriora laczyc sygnal _on_target_clicked, pozniej bedzie to w spawn_enemy()
	$HumanWarrior.connect("target_clicked", _on_target_clicked)
	$HumanWarrior2.connect("target_clicked", _on_target_clicked)
	$HumanWarrior3.connect("target_clicked", _on_target_clicked)

func _on_target_clicked(body):
	print("przyjalem sygnal od warriora")
	for unit in get_tree().get_nodes_in_group("Selected"):
		unit.attack_target = weakref(body)
		unit.state_machine.set_state(unit.state_machine.states.engaging)

#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	spawn_enemy()

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#if event.pressed:
			#for unit in get_tree().get_nodes_in_group('Selected'):
				#unit.move_to(get_global_mouse_position())

#	       ⠀⠀⠀⠀⢀⣴⣶⠿⠟⠻⠿⢷⣦⣄⠀⠀⠀
#	⠀       ⠀⠀⠀⣾⠏⠀⠀⣠⣤⣤⣤⣬⣿⣷⣄⡀
#	       ⠀⢀⣀⣸⡿⠀⠀⣼⡟⠁⠀⠀⠀⠀⠀⠙⣷
#	       ⢸⡟⠉⣽⡇⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⢀⣿
#	       ⣾⠇⠀⣿⡇⠀⠀⠘⠿⢶⣶⣤⣤⣶⡶⣿⠋
#	       ⣿⠂⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠃
#	       ⣿⡆⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀
#	       ⢿⡇⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠀
#	       ⠘⠻⠷⢿⡇⠀⠀⠀⣴⣶⣶⠶⠖⠀⢸⡟⠀
#	       ⠀⠀⠀⢸⣇⠀⠀⠀⣿⡇⣿⡄⠀⢀⣿⠇⠀
#	       ⠀⠀⠀⠘⣿⣤⣤⣴⡿⠃⠙⠛⠛⠛⠋⠀⠀
	
  
#Tworzenie i odgrywanie animacji ze strzaleczkami kiedy wydajemy rozkaz ruchu
#prawdopodobnie trzeba bedzie tu dodac ifa w przyszlosci kiedy dodamy targetowanie przeciwnika
#right clickiem
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released():
			cursor_move_animation()
	elif event.is_action_pressed("EscMenu"):
		get_tree().change_scene_to_file("res://scenes/ui/esc_menu.tscn")

func cursor_move_animation() -> void:
	if get_tree().get_nodes_in_group("Selected"):
		var new_move_cursor = preload("res://scenes/ui/move_cursor.tscn").instantiate()
		new_move_cursor.global_position = get_global_mouse_position()
		new_move_cursor.play("default")
		$MoveCursor.add_child(new_move_cursor)
		await new_move_cursor.animation_finished
		new_move_cursor.queue_free()
