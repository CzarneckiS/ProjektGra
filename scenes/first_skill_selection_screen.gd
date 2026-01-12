extends Node2D

func _ready() -> void:
		var tween1 = create_tween()
		tween1.tween_property($Skull,"modulate:a",1,0.5)
		await get_tree().create_timer(2).timeout
		show_lvl_up_menu()
		await get_tree().create_timer(1).timeout
		var tween3 = create_tween()
		tween3.tween_property($Skull,"modulate:a",0,0.5)
		await tween3.finished
		get_tree().change_scene_to_file("res://scenes/levels/level.tscn")

func show_lvl_up_menu():  
	get_tree().paused = true
	var lvl_up_upgrades_menu = preload("res://scenes/ui/lvlup_menu.tscn").instantiate()
	lvl_up_upgrades_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	$LvlUpUpgradesLayer.add_child(lvl_up_upgrades_menu)
