extends Node2D

@onready var move_cursor = $MoveCursor
 


func _ready():
	#musimy dla kazdej instancji warriora laczyc sygnal _on_target_clicked, pozniej bedzie to w spawn_enemy()
	$HumanWarrior.connect("target_clicked", _on_target_clicked)
	$HumanWarrior2.connect("target_clicked", _on_target_clicked)
	$HumanWarrior3.connect("target_clicked", _on_target_clicked)

#SPAWNING PRZECIWNIKÓW ================================================================
func spawn_enemy(): # EnemySpawnFollow bierzemy jako unique name
	var new_enemy = preload("res://scenes/characters/enemies/humanwarrior.tscn").instantiate()
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	new_enemy.global_position = %EnemySpawnFollow.global_position
	#new_enemy.connect("target_clicked", _on_target_clicked)
	add_child(new_enemy)

#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	spawn_enemy()

#INPUTS ==========================================================================
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_released(): #Jeśli right clickujesz
			return
		if get_tree().get_nodes_in_group("Selected"): #sprawdza czy zselectowaliśmy jakąś jednostkę
			cursor_move_animation()  #Odegraj animację
	elif event.is_action_pressed("EscMenu"):
		#JAK COS TO TRZEBA TU VAR BO USUWAMY TE ZMIENNE 
		#PO TYM JAK WCISKAMY CONTINUE W ESCMENU
		if not $MenuLayer.has_node("EscMenu"):
			var esc_menu_scene = load("res://scenes/ui/esc_menu.tscn")
			var esc_menu = esc_menu_scene.instantiate()
			esc_menu.name = "EscMenu"               
			esc_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			$MenuLayer.add_child(esc_menu)
			get_tree().paused = true
	
	elif event.is_action_pressed("tmpLvlUp"):
		if not $MenuLayer.has_node("LvlUpMenu"):
			var lvlup_scene = load("res://scenes/ui/lvlup_menu.tscn")
			var lvlup_menu = lvlup_scene.instantiate()
			lvlup_menu.name = "LvlUpMenu"               
			lvlup_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			$MenuLayer.add_child(lvlup_menu)
			get_tree().paused = true

func _on_target_clicked(body): #Sygnał od human warriora, czy został kliknięty
	print("przyjalem sygnal od warriora")
	for unit in get_tree().get_nodes_in_group("Selected"): #Jeśli jednostka jest zaznaczona
		unit.attack_target = weakref(body) #wyślij do niej human warriora jako cel ataku
		unit.state_machine.set_state(unit.state_machine.states.engaging)

func cursor_move_animation() -> void: #Animacja przy right clickowaniu na ziemię
		var new_move_cursor = preload("res://scenes/ui/move_cursor.tscn").instantiate()
		new_move_cursor.global_position = get_global_mouse_position()
		new_move_cursor.play("default")
		$MoveCursor.add_child(new_move_cursor)
		await new_move_cursor.animation_finished
		new_move_cursor.queue_free()
		
#To niech zostanie, może w przyszłości tutaj będziemy wydawać rozkazy movementu jednostkom
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
	
