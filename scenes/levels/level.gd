extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("EscMenu"):
		get_tree().change_scene_to_file("res://scenes/ui/esc_menu.tscn")
	

# EnemySpawnFollow bierzemy jako unique name
func spawn_enemy():
	var new_enemy = preload("res://scenes/characters/enemies/humanwarrior.tscn").instantiate()
	%EnemySpawnFollow.progress_ratio = randf() #wybiera losowy punkt na sciezce i z tego miejsca bedzie respiony mobek
	new_enemy.global_position = %EnemySpawnFollow.global_position
	add_child(new_enemy)

#timer okresla co jaki czas bedzie respiony mob, feel free to change
func _on_timer_timeout() -> void:
	spawn_enemy()

#ROZKAZ RUCHU
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#if event.pressed:
			#for unit in get_tree().get_nodes_in_group('Selected'):
				#unit.move_to(get_global_mouse_position())
