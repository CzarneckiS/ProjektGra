extends Node

var health = 100
var max_health 
var xp = 0
var max_xp
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
