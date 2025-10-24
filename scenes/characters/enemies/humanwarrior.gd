extends UnitParent

#ustawic na false :*
#thought - nie robic tak, ze mobki ida PROSTO na gracza od razu
#tylko dla coolnosci zrobic tak ze ida kawalek w mniej wiecej kierunku gracza
#i sie zatrzymuja i nazwac ten stan wandering dla realizmu????? idk idk
var player_seen: bool = false
var speed = 300

#he be walkin' towards the player at the moment
func _process(_delta: float) -> void:
	var direction = (Globals.player_position - global_position).normalized()
	velocity = direction * speed
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	move_and_slide()
