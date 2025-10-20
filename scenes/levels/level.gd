extends Node2D


#ROZKAZ RUCHU
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#if event.pressed:
			#for unit in get_tree().get_nodes_in_group('Selected'):
				#unit.move_to(get_global_mouse_position())
