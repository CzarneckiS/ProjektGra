extends Node2D

@onready var move_cursor = $MoveCursor
@onready var unit_selector: Node2D = $UnitSelector
var attack_move_input: bool = false
var hud = load("res://scenes/levels/hud.tscn").instantiate()              
var human_warrior = preload("res://scenes/characters/enemies/humanwarrior.tscn")
var human_archer = preload("res://scenes/characters/enemies/humanarcher.tscn")
var human_mage = preload("res://scenes/characters/enemies/humanmage.tscn")
var skeleton_warrior = preload("res://scenes/characters/allies/skeletonwarrior.tscn")
var skeleton_mage = preload("res://scenes/characters/allies/skeletonmage.tscn")

var stats_hud = load("res://scenes/levels/hud.tscn").instantiate() 
var minions_selections_hud = load("res://scenes/levels/hud.tscn").instantiate()
var command_spells_hud = load("res://scenes/levels/hud.tscn").instantiate() 
#var lvl_up_upgrades_menu = load("res://scenes/ui/lvlup_menu.tscn").instantiate()


func _ready():
	$Player.connect("summon_unit", on_summon_unit)
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	$HudLayer.add_child(hud)
	#tu chyba nie powinno byc podlogi przed nazwa sygnalu? idk juz sie w tym pogubilem
	Globals.lvl_up_menu_requested.connect(show_lvl_up_menu)
	stats_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	#lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$HudLayer.add_child(stats_hud)
	
	$Player/EnemySpawnArea/Timer.connect("timeout", _on_timer_timeout)
	#musimy dla kazdej instancji warriora laczyc sygnal _on_target_clicked, pozniej bedzie to w spawn_enemy()
	$EnemyUnits/HumanWarrior.connect("target_clicked", _on_target_clicked)
	#$HumanWarrior2.connect("target_clicked", _on_target_clicked)
	#$HumanWarrior3.connect("target_clicked", _on_target_clicked)           

func _process(_delta: float) -> void:
	pass #do testow
	$HudLayer/Label2.text = "fps: " + str(Engine.get_frames_per_second())

#SPAWNING JEDNOSTEK ================================================================

func show_lvl_up_menu():
	get_tree().paused = true
	var lvl_up_upgrades_menu = preload("res://scenes/ui/lvlup_menu.tscn").instantiate()
	lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$LvlUpUpgradesLayer.add_child(lvl_up_upgrades_menu)




func spawn_enemy(): # EnemySpawnFollow bierzemy jako unique name
	var new_enemy = human_warrior.instantiate()
	$EnemyUnits.add_child(new_enemy)
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	while !is_point_on_map(%EnemySpawnFollow.global_position):
		%EnemySpawnFollow.progress_ratio = randf()
	new_enemy.global_position = %EnemySpawnFollow.global_position
	new_enemy.connect("target_clicked", _on_target_clicked)
var test = 0
#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	if test <= 300: #temporary, spawni mobki az nie bedzie ich 300
		spawn_enemy()
		test += 1
		#print(test)

func on_summon_unit(unit):
	match unit:
		"SkeletonWarrior":
			print("summon skeleton warrior")
			summon_skeleton_warrior()
		"SkeletonMage":
			print("summon skeleton mage")
			summon_skeleton_mage()
func on_unit_death(unit):
	match unit:
		"SkeletonWarrior":
			await get_tree().create_timer(1.0).timeout
			summon_skeleton_warrior()
		"SkeletonMage":
			await get_tree().create_timer(1.0).timeout
			summon_skeleton_mage()
#Ta funkcja moze byc potencjalnie grozna bo uzywa WHILE !
#uzywanie while podczas runtime gry moze oznaczac lagi i wtedy moze trzeba zrobic cos takiego:
#funkcja w while ma np 60 prob zanim sie podda
#i rozpoczyna kalkulacje od nowa w nastepnym frame
#czyli rozkladamy kalkulacje na kilka framow zeby uniknac lagow :) 
func get_random_point_in_radius(radius: int = 200) -> Vector2:
	var point := Vector2(randf_range(Globals.player_position.x-radius, Globals.player_position.x+radius),\
	randf_range(Globals.player_position.y-radius, Globals.player_position.y+radius))
	while !is_point_on_map(point):
		point = Vector2(randf_range(Globals.player_position.x-radius, Globals.player_position.x+radius),\
	randf_range(Globals.player_position.y-radius, Globals.player_position.y+radius))
	return point
func summon_skeleton_warrior():
	var new_skeleton_warrior = skeleton_warrior.instantiate()
	$AlliedUnits.add_child(new_skeleton_warrior)
	new_skeleton_warrior.global_position = get_random_point_in_radius()
	new_skeleton_warrior.connect("unit_died", on_unit_death)
func summon_skeleton_mage():
	var new_skeleton_mage = skeleton_mage.instantiate()
	$AlliedUnits.add_child(new_skeleton_mage)
	#%AllySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	#while !is_point_on_map(%AllySpawnFollow.global_position):
		#%AllySpawnFollow.progress_ratio = randf()
	#new_skeleton_mage.global_position = %AllySpawnFollow.global_position
	new_skeleton_mage.global_position = get_random_point_in_radius()
	new_skeleton_mage.connect("unit_died", on_unit_death)



func is_point_on_map(target_point: Vector2) -> bool:
	var map = get_world_2d().navigation_map
	var closest_point = NavigationServer2D.map_get_closest_point(map, target_point)
	var difference = closest_point - target_point
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
	elif event.is_action_pressed("tmpSpawnAlly1"):
		summon_skeleton_warrior()
	elif event.is_action_pressed("tmpSpawnAlly2"):
		summon_skeleton_mage()
	elif event.is_action_pressed("tmpSpawnEnemy"):
		spawn_enemy()
	elif event.is_action_pressed("tmpSpawnEnemy2"):
		var new_enemy = human_archer.instantiate()
		$EnemyUnits.add_child(new_enemy)
		%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
		while !is_point_on_map(%EnemySpawnFollow.global_position):
			%EnemySpawnFollow.progress_ratio = randf()
		new_enemy.global_position = %EnemySpawnFollow.global_position
		new_enemy.connect("target_clicked", _on_target_clicked)
	elif event.is_action_pressed("tmpSpawnEnemy3"):
		var new_enemy = human_mage.instantiate()
		$EnemyUnits.add_child(new_enemy)
		%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
		while !is_point_on_map(%EnemySpawnFollow.global_position):
			%EnemySpawnFollow.progress_ratio = randf()
		new_enemy.global_position = %EnemySpawnFollow.global_position
		new_enemy.connect("target_clicked", _on_target_clicked)



func _on_target_clicked(body): #Sygnał od human warriora, czy został kliknięty
	print("przyjalem sygnal od warriora")
	for unit in get_tree().get_nodes_in_group("Selected"): #Jeśli jednostka jest zaznaczona
		unit.attack_target = body #wyślij do niej human warriora jako cel ataku
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
	
