extends CharacterBody2D

#! ! ! 90% rzeczy tutaj jest temporary ! ! ! 
#wiec nie bede tego komentować 

var speed = 500
var standing: bool = true
var selected = false

func _unhandled_input(event):
	if event.is_action_pressed("fireball_input"):
		cast_fireball()
	if event.is_action_pressed("thunderbolt_input"):
		cast_thunderbolt()

var fireball_skill: Resource = preload("res://resources/fireball.tres")
var thunderbolt_skill: Resource = preload("res://resources/thunderbolt.tres")
var skill_cooldowns: Dictionary = {}

func can_cast(skill: Resource) -> bool:
	var key = skill.resource_path
	
	if !skill_cooldowns.has(key):
		return true
	return Time.get_ticks_msec() / 1000.0 >= skill_cooldowns[key]

func set_cooldown(skill: Resource):
	var key = skill.resource_path
	
	var current_time = Time.get_ticks_msec() / 1000.0
	skill_cooldowns[key] = current_time + skill.cooldown
	
func cast_fireball():
	if !can_cast(fireball_skill):
		return
	
	set_cooldown(fireball_skill)
	
	var target_pos: Vector2 = get_global_mouse_position()
	if fireball_skill is Fireball:
		fireball_skill.use(self, target_pos)

func cast_thunderbolt():
	if !can_cast(thunderbolt_skill):
		return
	
	set_cooldown(thunderbolt_skill)
	
	var target_pos: Vector2 = get_global_mouse_position()
	if thunderbolt_skill is Thunderbolt:
		thunderbolt_skill.use(self, target_pos)

var hp_bar_style = StyleBoxFlat.new()

@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar


func _ready() -> void:
	
	Globals.health = 200
	Globals.max_health = 200
	Globals.xp = 25
	Globals.max_xp = 100
	
	health_bar.max_value = Globals.health
	health_bar.value = Globals.health
	health_bar.visible = false
	damage_bar.max_value = Globals.health
	damage_bar.value = Globals.health
	damage_bar.visible = false
	
	
	hp_bar_style.bg_color = Color("ba0098ff")
	hp_bar_style.border_width_left = 2
	hp_bar_style.border_width_top = 2
	hp_bar_style.border_width_bottom = 2
	hp_bar_style.border_color = Color(0.0, 0.0, 0.0, 1.0)
	health_bar.add_theme_stylebox_override("fill", hp_bar_style)
	
		
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



func hit(damage_taken, _damage_source) -> void:
	health_bar.visible = true
	damage_bar.visible = true

	Globals.health -= damage_taken
	health_bar.value = Globals.health
	var health_tween = create_tween()
	health_tween.tween_property(damage_bar, "value", Globals.health, 0.5) 
	health_tween.set_trans(Tween.TRANS_SINE)
	health_tween.set_ease(Tween.EASE_OUT)
	
	Globals.xp += 5
	
	#if Globals.health <= 0:
	#	health_bar.visible = false
	#	damage_bar.visible = false
	#	animacja_smierci() + menu_ze_przegrales()
		
#func select() -> void:
	#add_to_group("Selected")
	#selected = true
	#$Selected.visible = true
	#
#func deselect() -> void:
	#remove_from_group("Selected")
	#selected = false
	#$Selected.visible = false
	#
#func is_in_selection_box(select_box: Rect2):
	#return select_box.has_point(global_position)
#
#func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_released:
			#print("selekcik gracza") #debug print 
			#select()

func flip() -> void:
	if $SpriteRoot.scale.x > 0:
		$SpriteRoot.scale.x *= -1

func unflip() -> void:
	if $SpriteRoot.scale.x < 0:
		$SpriteRoot.scale.x *= -1
