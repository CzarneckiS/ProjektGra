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
	print()
	$Player.connect("summon_unit", on_summon_unit)
	$Player.connect("took_damage", on_unit_damage_taken)
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	$HudLayer.add_child(hud)
	#tu chyba nie powinno byc podlogi przed nazwa sygnalu? idk juz sie w tym pogubilem
	Globals.lvl_up_menu_requested.connect(show_lvl_up_menu)
	stats_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	#lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$HudLayer.add_child(stats_hud)
	$Player/EnemySpawnArea/Timer.connect("timeout", _on_timer_timeout)
	add_child(timer_between_waves)
	timer_between_waves.autostart = false
	timer_between_waves.one_shot = true
	timer_between_waves.wait_time = 1
	timer_between_waves.timeout.connect(wave_logic)
	timer_between_waves.start()
	
func _process(_delta: float) -> void:
	$HudLayer/Label2.text = "fps: " + str(Engine.get_frames_per_second())
	
func show_lvl_up_menu():  
	get_tree().paused = true
	var lvl_up_upgrades_menu = preload("res://scenes/ui/lvlup_menu.tscn").instantiate()
	lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$LvlUpUpgradesLayer.add_child(lvl_up_upgrades_menu)



#SPAWNING JEDNOSTEK ================================================================
var enemies_defeated: int = 0
var enemies_spawned: int = 0
var enemies_to_spawn: int = 0
var wave_counter: int = 1
var max_wave: int = 30
var h_warriors_to_spawn: int = 2
var h_mages_to_spawn: int = 1
var h_archers_to_spawn: int = 1
var timer_between_waves: Timer = Timer.new()

func wave_logic():
	print("ile pokonano: ", enemies_defeated)
	print("ile zespawniono: ", enemies_spawned)
	print("ile ma byc zespawnione: ", enemies_to_spawn)
	
	if wave_counter == max_wave:
		return
	if enemies_defeated >= enemies_spawned:
		enemy_spawn_by_wave(wave_counter)
		new_wave()
		wave_counter += 1
	timer_between_waves.call_deferred("start")
	
func new_wave():
	enemies_defeated = 0 #sygnał od unitów on_death aktualizuje zmienna
	for warriors in range(h_warriors_to_spawn):
		spawn_enemy(human_warrior)
	for mages in range(h_mages_to_spawn):
		spawn_enemy(human_mage)
	for archers in range(h_archers_to_spawn):
		spawn_enemy(human_archer)
	enemies_spawned = enemies_to_spawn
	
func enemy_spawn_by_wave(wave_number):
	enemies_to_spawn = 0
	wave_number = wave_counter
	
	var h_warriors_spawn_increase: int = 1
	var h_mages_spawn_increase: int = 1
	var h_archers_spawn_increase: int = 1
	
	if wave_number % 2 == 0:
		h_warriors_to_spawn += h_warriors_spawn_increase
	if wave_number % 3 == 0:
		h_mages_to_spawn += h_mages_spawn_increase
	if wave_number % 4 == 0:
		h_archers_to_spawn += h_archers_spawn_increase
	
	enemies_to_spawn = h_warriors_to_spawn + h_mages_to_spawn + h_archers_to_spawn
	
func spawn_enemy(enemy_type): # EnemySpawnFollow bierzemy jako unique name
	var new_enemy = enemy_type.instantiate()
	$EnemyUnits.add_child(new_enemy)
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	#while !is_point_on_map(%EnemySpawnFollow.global_position):
	%EnemySpawnFollow.progress_ratio = randf()
	new_enemy.global_position = %EnemySpawnFollow.global_position
	new_enemy.connect("target_clicked", _on_target_clicked)
	new_enemy.connect("took_damage", on_unit_damage_taken)
	new_enemy.connect("unit_died", on_unit_death)
var test = 0
#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	if test <= 300: #temporary, spawni mobki az nie bedzie ich 300
		#spawn_enemy(enemy_type)
		test += 1
		#print(test)

func on_summon_unit(unit):
	match unit:
		"SkeletonWarrior":
			summon_skeleton_warrior()
		"SkeletonMage":
			summon_skeleton_mage()
			
func on_unit_death(unit):
	#narazie hardcoded 5 sekundowy timer
	for order in movement_orders:
			if unit in order.unit_array:
				order.unit_array.erase(unit)
	match unit:
		Tags.UnitTag.SKELETON_MAGE:
			await get_tree().create_timer(5.0).timeout
			summon_skeleton_mage()
		Tags.UnitTag.SKELETON_WARRIOR:
			await get_tree().create_timer(5.0).timeout
			summon_skeleton_warrior()
		Tags.UnitTag.HUMAN_WARRIOR:
			enemies_defeated += 1
			Achievements.achievement_update(Achievements.Event.ENTITY_DIED, Tags.UnitTag.HUMAN_WARRIOR)
		Tags.UnitTag.HUMAN_ARCHER:
			enemies_defeated += 1
			Achievements.achievement_update(Achievements.Event.ENTITY_DIED, Tags.UnitTag.HUMAN_ARCHER)
		Tags.UnitTag.HUMAN_MAGE:
			enemies_defeated += 1
			Achievements.achievement_update(Achievements.Event.ENTITY_DIED, Tags.UnitTag.HUMAN_MAGE)
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
	new_skeleton_warrior.connect("took_damage", on_unit_damage_taken)
	on_allied_unit_spawn_animation(new_skeleton_warrior)
func summon_skeleton_mage():
	var new_skeleton_mage = skeleton_mage.instantiate()
	$AlliedUnits.add_child(new_skeleton_mage)
	#%AllySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	#while !is_point_on_map(%AllySpawnFollow.global_position):
		#%AllySpawnFollow.progress_ratio = randf()
	#new_skeleton_mage.global_position = %AllySpawnFollow.global_position
	new_skeleton_mage.global_position = get_random_point_in_radius()
	new_skeleton_mage.connect("unit_died", on_unit_death)
	new_skeleton_mage.connect("took_damage", on_unit_damage_taken)
	on_allied_unit_spawn_animation(new_skeleton_mage)

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
		if attack_move_input:
			attack_move_input = false
			unit_selector.attack_move_input = false
			Globals.attack_move_input_ended() #do grafiki kursora
		elif get_tree().get_nodes_in_group("Selected"): #sprawdza czy zselectowaliśmy jakąś jednostkę
			cursor_move_animation()  #Odegraj animację
			for unit in get_tree().get_nodes_in_group("Selected"):
				unit.handle_inputs("right_click")
				create_movement_order_stop_area()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_released():
			return
		if attack_move_input:
			attack_move_input = false
			unit_selector.attack_move_input = false
			Globals.attack_move_input_ended() #do grafiki kursora
			if Globals.overlapping_enemies <= 0:
				if get_tree().get_nodes_in_group("Selected"): #sprawdza czy zselectowaliśmy jakąś jednostkę
					cursor_attack_move_animation()
					for unit in get_tree().get_nodes_in_group("Selected"):
						unit.handle_inputs("left_click")
						create_movement_order_stop_area()
	elif event.is_action_pressed("attack_move"):
		if get_tree().get_nodes_in_group("Selected"):
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
		if attack_move_input: #przywroc kursor do normy jesli klikalismy A przed ESC
			attack_move_input = false
			unit_selector.attack_move_input = false
			Globals.attack_move_input_ended() #do grafiki kursora
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
		spawn_enemy(human_warrior)
	elif event.is_action_pressed("tmpSpawnEnemy2"):
		var new_enemy = human_archer.instantiate()
		$EnemyUnits.add_child(new_enemy)
		%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
		while !is_point_on_map(%EnemySpawnFollow.global_position):
			%EnemySpawnFollow.progress_ratio = randf()
		new_enemy.global_position = %EnemySpawnFollow.global_position
		new_enemy.connect("target_clicked", _on_target_clicked)
		new_enemy.connect("took_damage", on_unit_damage_taken)
		new_enemy.connect("unit_died", on_unit_death)
	elif event.is_action_pressed("tmpSpawnEnemy3"):
		var new_enemy = human_mage.instantiate()
		$EnemyUnits.add_child(new_enemy)
		%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
		while !is_point_on_map(%EnemySpawnFollow.global_position):
			%EnemySpawnFollow.progress_ratio = randf()
		new_enemy.global_position = %EnemySpawnFollow.global_position
		new_enemy.connect("target_clicked", _on_target_clicked)
		new_enemy.connect("took_damage", on_unit_damage_taken)
		new_enemy.connect("unit_died", on_unit_death)

#MOVEMENT ======================================================================================
var movement_orders : Array = []
func create_movement_order_stop_area():
	#do przetestowania, potencjalny memory leak w kombinacji z funkcja follow_player?
	var selected_units_order = preload("res://scripts/unit_movement/unit_move_stop_area.tscn").instantiate()
	add_child(selected_units_order)
	selected_units_order.global_position = get_global_mouse_position()
	for unit in get_tree().get_nodes_in_group("Selected"):
		for order in movement_orders:
			if unit in order.unit_array:
				order.unit_array.erase(unit)
		selected_units_order.unit_array.append(unit)
		unit.movement_order = weakref(selected_units_order)
	movement_orders.append(selected_units_order)
	for order in movement_orders:
		for reference in order.unit_array:
			if reference == null:
				order.unit_array.erase(reference)
		if order.unit_array.size() <= 0:
			movement_orders.erase(order)
			order.queue_free()

#VISUALS =======================================================================================
func on_allied_unit_spawn_animation(unit):
	var spawn_animation = preload("res://vfx/spawn_animation.tscn").instantiate()
	add_child(spawn_animation)
	spawn_animation.global_position = unit.global_position
	spawn_animation.play("default")
	await spawn_animation.animation_finished
	spawn_animation.queue_free()

func on_unit_damage_taken(damage, unit):
	var damage_number = Label.new()
	add_child(damage_number)
	damage_number.text = str(damage)
	damage_number.global_position = unit.global_position
	damage_number.global_position.y -= 100 #hardcoded 100 pixeli w gore od srodka jednostki, moze do poprawy
	damage_number.z_index = 3
	damage_number.label_settings = LabelSettings.new()
	var color = "#FFF"
	damage_number.label_settings.font_size = 30
	if unit in get_tree().get_nodes_in_group("Allied"):
		damage_number.text = ("-"+str(damage))
		color = "#F00"
		if unit in get_tree().get_nodes_in_group("Player"):
			damage_number.label_settings.font_size = 36
	damage_number.label_settings.font_color = color

	damage_number.label_settings.outline_color = "#000"
	damage_number.label_settings.outline_size = 5
	damage_number.pivot_offset = Vector2(damage_number.size / 2)
	damage_number.label_settings.font = preload("res://misc/fonts/upheavtt.ttf")
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_number,"global_position:y",damage_number.global_position.y - 20, 0.5)
	tween.tween_property(damage_number,"global_position:x",damage_number.global_position.x + randi_range(-20, 20), 0.5)
	await tween.finished
	damage_number.queue_free()
func _on_target_clicked(body): #Sygnał od human warriora, czy został kliknięty
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

func cursor_attack_move_animation() -> void: #Animacja przy attack move clickowaniu na ziemię
		var new_move_cursor = preload("res://scenes/ui/attack_cursor.tscn").instantiate()
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
	
