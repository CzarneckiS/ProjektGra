extends CharacterBody2D

var speed = 500
var health = 100
var standing: bool = true

#TEMPORARY ! ! ! ! !
signal spawn (mouse_position)

func _process(_delta: float) -> void:
	if standing:
		$AnimationPlayer.play("stand")
	standing = true
	# TRZEBA JEJ ZROBIC TEZ MOVEMENT Z KLIKANIEM TO JEST PLAAACEHOOOLDER
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction != Vector2.ZERO:
		if Input.is_action_pressed("move_right"):
			flip()
		else:
			unflip()
		$AnimationPlayer.play("walk")
		standing = false
		velocity = direction * speed
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		move_and_slide()
	Globals.player_position = global_position
	#if Input.is_action_pressed("left_click"):
	#	spawn.emit(get_viewport().get_mouse_position())

func hit(damage) -> void:
	#le hit function, pobiera dane od tego co zaatakowalo zeby hp spadlo o dmg ;3
	health -= damage
	
	
#FIX : JEJ AHOGE BECAUSE I FUCKED UP BADLY ALE PORA SPAC

func flip() -> void:
	if $SpriteRoot.scale.x > 0:
		$SpriteRoot.scale.x *= -1

func unflip() -> void:
	if $SpriteRoot.scale.x < 0:
		$SpriteRoot.scale.x *= -1
