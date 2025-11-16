extends Node2D

@onready var move_cursor = $MoveCursor
@onready var unit_selector: Node2D = $UnitSelector
var attack_move_input: bool = false

var stats_hud = load("res://scenes/levels/hud.tscn").instantiate() 
var minions_selections_hud = load("res://scenes/levels/hud.tscn").instantiate()
var command_spells_hud = load("res://scenes/levels/hud.tscn").instantiate() 
#var lvl_up_upgrades_menu = load("res://scenes/ui/lvlup_menu.tscn").instantiate()


func _ready():
	Globals.lvl_up_menu_requested.connect(show_lvl_up_menu)
	stats_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	#lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$HudLayer.add_child(stats_hud)
	
	#musimy dla kazdej instancji warriora laczyc sygnal _on_target_clicked, pozniej bedzie to w spawn_enemy()
	$EnemyUnits/HumanWarrior.connect("target_clicked", _on_target_clicked)
	#$HumanWarrior2.connect("target_clicked", _on_target_clicked)
	#$HumanWarrior3.connect("target_clicked", _on_target_clicked)           


func _process(_delta: float) -> void:
	pass #do testow
	$HudLayer/Label2.text = "fps: " + str(Engine.get_frames_per_second())


func show_lvl_up_menu():
	get_tree().paused = true
	var lvl_up_upgrades_menu = preload("res://scenes/ui/lvlup_menu.tscn").instantiate()
	lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$LvlUpUpgradesLayer.add_child(lvl_up_upgrades_menu)



#SPAWNING PRZECIWNIKÓW ================================================================
func spawn_enemy(): # EnemySpawnFollow bierzemy jako unique name
	var new_enemy = preload("res://scenes/characters/enemies/humanwarrior.tscn").instantiate()
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	while !is_point_on_map(%EnemySpawnFollow.global_position):
		%EnemySpawnFollow.progress_ratio = randf()
	new_enemy.global_position = %EnemySpawnFollow.global_position
	add_child(new_enemy)
	
var test = 0
#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	if test <= 300: #temporary, spawni mobki az nie bedzie ich 300
		spawn_enemy()
		test += 1
		#print(test)

func is_point_on_map(target_point: Vector2) -> bool:
	var map := get_world_2d().navigation_map
	var closest_point := NavigationServer2D.map_get_closest_point(map, target_point)
	var difference := closest_point - target_point
	if difference.is_zero_approx():
		return true
	else:
		return false
#INPUTS ==========================================================================
func _unhandled_input(event: InputEvent) -> void:
	#ROZKAZY DLA JEDNOSTEK ==================
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_released(): #Jeśli right clickujesz
			return
		if get_tree().get_nodes_in_group("Selected"): #sprawdza czy zselectowaliśmy jakąś jednostkę
			cursor_move_animation()  #Odegraj animację
			for unit in get_tree().get_nodes_in_group("Selected"):
				unit.handle_inputs("right_click")
		if attack_move_input:
			attack_move_input = false
			unit_selector.attack_move_input = false
			Globals.attack_move_input_ended()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_released():
			return
		if attack_move_input:
			attack_move_input = false
			unit_selector.attack_move_input = false
			Globals.attack_move_input_ended()
			if Globals.overlapping_enemies <= 0:
				if get_tree().get_nodes_in_group("Selected"): #sprawdza czy zselectowaliśmy jakąś jednostkę
					cursor_move_animation()
					for unit in get_tree().get_nodes_in_group("Selected"):
						unit.handle_inputs("left_click")
	elif event.is_action_pressed("attack_move"):
		Globals.attack_move_input_pressed()
		unit_selector.attack_move_input = true
		attack_move_input = true
		for unit in get_tree().get_nodes_in_group("Selected"):
			unit.handle_inputs("attack_move")
	elif event.is_action_pressed("stop"):
		for unit in get_tree().get_nodes_in_group("Selected"):
				unit.handle_inputs("stop")
	elif event.is_action_pressed("hold"):
		for unit in get_tree().get_nodes_in_group("Selected"):
				unit.handle_inputs("hold")
		#INPUTY DO UI ==================
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
		#TEMPORARY INPUTY ==================
	elif event.is_action_pressed("tmpLvlUp"):
		if not $MenuLayer.has_node("LvlUpMenu"):
			var lvlup_scene = load("res://scenes/ui/lvlup_menu.tscn")
			var lvlup_menu = lvlup_scene.instantiate()
			lvlup_menu.name = "LvlUpMenu"               
			lvlup_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			$MenuLayer.add_child(lvlup_menu)
			get_tree().paused = true
	elif event.is_action_pressed("tmpSpawnAlly"):
		var new_ally = preload("res://scenes/characters/allies/skeletonmage.tscn").instantiate()
		new_ally.global_position = get_global_mouse_position()
		add_child(new_ally)

		
	elif event.is_action_pressed("tmpSpawnEnemy"):
		spawn_enemy()

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
	
