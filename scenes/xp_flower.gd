extends Area2D

var xp_value = (Globals.xp_to_level/2)

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(_body):
	Globals.update_player_exp(xp_value)
	queue_free()
