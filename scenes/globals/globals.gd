extends Node


signal stats_changed

var health = 100:
	get():
		return health
	set(value):
		health = value
		stats_changed.emit()
		
var max_health = 100:
	get():
		return max_health
	set(value):
		max_health = value
		stats_changed.emit()
		
var xp = 0:
	get():
		return xp
	set(value):
		xp = value
		stats_changed.emit()

var max_xp = 100:
	get():
		return max_xp
	set(value):
		max_xp = value
		stats_changed.emit()
		
		
var level
var player_position: Vector2
var target = Vector2.ZERO

func level_up():
	max_health += 20
	xp -= max_xp #nadwyzka expa przechodzi dalej
	max_xp += 100 #nw czy obchodzi nas ladne skalowanie sie expa :b 
	update_ui()
	

	
	

func update_ui():
	pass
