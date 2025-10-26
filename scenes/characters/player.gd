extends CharacterBody2D

var speed = 500
var health = 100
var standing: bool = true
var selected = false

func _ready() -> void:
	$ClickArea.input_event.connect(_on_click_area_input_event)

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

func hit(damage) -> void:
	#le hit function, pobiera dane od tego co zaatakowalo zeby hp spadlo o dmg ;3
	health -= damage
		
func select() -> void:
	add_to_group("Selected")
	selected = true
	$Selected.visible = true
	
func deselect() -> void:
	remove_from_group("Selected")
	selected = false
	$Selected.visible = false
	
func is_in_selection_box(select_box: Rect2):
	return select_box.has_point(global_position)

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print('im alive!')
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released:
			select()


func flip() -> void:
	if $SpriteRoot.scale.x > 0:
		$SpriteRoot.scale.x *= -1

func unflip() -> void:
	if $SpriteRoot.scale.x < 0:
		$SpriteRoot.scale.x *= -1
