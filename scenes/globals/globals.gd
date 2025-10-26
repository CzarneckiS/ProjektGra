extends Node

#statystyki głównej jednostki
var health = 100
var max_health 
var player_position: Vector2

#exp i levelowanie
var xp = 0
var max_xp
var level

#mr oskar jak cos to sa STARE placeholdery z tym level up, rob tutaj jak uwazasz
func level_up():
	max_health += 20
	xp -= max_xp #nadwyzka expa przechodzi dalej
	max_xp += 100 #nw czy obchodzi nas ladne skalowanie sie expa :b 

func update_ui():
	#ta funkcja bedzie do updateowania duzego health bara na dole ekranu
	pass
