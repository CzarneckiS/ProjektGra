extends CharacterBody2D

#! ! ! 90% rzeczy tutaj jest temporary ! ! ! 
#wiec nie bede tego komentować 

var speed = 500
var standing: bool = true
var selected = false
var dying : bool = false

var skills_summon : Array = []
var skills_stat_up : Array = []
var skills_passive : Array = []
var skills_active : Array = []
var own_tags : PackedInt32Array = [Tags.UnitTag.PLAYER]

#Unit spawning
var skeleton_warrior_count = 0
var skeleton_mage_count = 0
signal summon_unit()
signal took_damage(damage, unit)

var unit_collision_push_array : Array = []
var direction : Vector2

func _unhandled_input(event):
	if event.is_action_pressed("fireball_input"):
		cast_fireball()
	if event.is_action_pressed("thunderbolt_input"):
		cast_thunderbolt()
	if event.is_action_pressed("heal_input"):
		cast_heal()
	if event.is_action_pressed("iceblock_input"):
		cast_iceblock()
	if event.is_action_pressed("field_input"):
		cast_field()

var fireball_skill: Resource = preload("res://resources/fireball.tres")
var thunderbolt_skill: Resource = preload("res://resources/thunderbolt.tres")
var heal_skill: Resource = preload("res://resources/heal.tres")
var iceblock_skill: Resource = preload("res://resources/iceblock.tres")
var field_skill: Resource = preload("res://resources/field.tres")
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
		
func cast_heal():
	if !can_cast(heal_skill):
		return
	
	set_cooldown(heal_skill)
	
	var player_pos: Vector2 = global_position
	if heal_skill is Heal:
		heal_skill.use(self, player_pos)
		
func cast_iceblock():
	if !can_cast(iceblock_skill):
		return
	
	set_cooldown(iceblock_skill)
	
	var target_pos: Vector2 = get_global_mouse_position()
	if iceblock_skill is Iceblock:
		iceblock_skill.use(self, target_pos)
		
func cast_field():
	if !can_cast(field_skill):
		return
	
	set_cooldown(field_skill)
	
	var target_pos: Vector2 = get_global_mouse_position()
	if field_skill is Field:
		field_skill.use(self, target_pos)

var hp_bar_style = StyleBoxFlat.new()

@onready var health_bar: ProgressBar = $HealthBar 
@onready var damage_bar: ProgressBar = $DamageBar


func _ready() -> void:
	handle_skills()
	handle_starting_skills()
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

	$Timers/HitFlashTimer.timeout.connect(_on_hit_flash_timer_timeout)
	for child in $SpriteRoot.get_children():
		child.use_parent_material = true
		for childs_child in child.get_children():
			childs_child.use_parent_material = true
	$MovementPushArea.connect("body_entered", _on_movement_push_area_body_entered)
	$MovementPushArea.connect("body_exited", _on_movement_push_area_body_exited)

func _physics_process(_delta: float) -> void:
	if standing:
		$AnimationPlayer.play("stand")
	standing = true
	# TRZEBA JEJ ZROBIC TEZ MOVEMENT Z KLIKANIEM TO JEST PLAAACEHOOOLDER
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction != Vector2.ZERO:
		push_units()
		if Input.is_action_pressed("move_right"):
			flip()
		else:
			unflip()
		$AnimationPlayer.play("walk")
		standing = false
		velocity = direction * speed
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		move_and_slide()
		direction = Vector2.ZERO
	Globals.player_position = global_position



#SKILLS ===============================================================================
func handle_skills():
	#dodaj do odpowiednich list umiejetnosci odblokowane
	for skill in Skills.unlocked_skills:
		for i in range(own_tags.size()):
			if skill.unit_tags.has(own_tags[i]):
				if skill.use_tags.has(Tags.UseTag.STAT_UP):
					skills_stat_up.append(skill)
				if skill.use_tags.has(Tags.UseTag.PASSIVE):
					skills_passive.append(skill)
				if skill.use_tags.has(Tags.UseTag.ACTIVE):
					skills_active.append(skill)
				if skill.use_tags.has(Tags.UseTag.SUMMON):
					skills_summon.append(skill)
				break
func handle_skill_update(skill):
	for i in range(own_tags.size()):
		if skill.unit_tags.has(own_tags[i]):
			if skill.use_tags.has(Tags.UseTag.STAT_UP):
				skills_stat_up.append(skill)
				skill.use(self)
			if skill.use_tags.has(Tags.UseTag.PASSIVE):
				skills_passive.append(skill)
				skill.use(self)
			if skill.use_tags.has(Tags.UseTag.ACTIVE):
				skills_active.append(skill)
			if skill.use_tags.has(Tags.UseTag.SUMMON):
				skills_summon.append(skill)
				skill.use(self)
			break
func handle_starting_skills():
	for skill in skills_stat_up:
		skill.use(self)
	for skill in skills_passive:
		skill.use(self)
	for skill in skills_summon:
		skill.use(self)

func hit(damage_taken, _damage_source) -> void:
	took_damage.emit(damage_taken, self) #do wyswietlania damage numbers
	$SpriteRoot.material.set_shader_parameter('progress',1)
	$Timers/HitFlashTimer.start()
	health_bar.visible = true
	damage_bar.visible = true
	health_bar.value = Globals.health
	var health_tween = create_tween()
	health_tween.tween_property(damage_bar, "value", Globals.health, 0.5)
	health_tween.set_trans(Tween.TRANS_SINE)
	health_tween.set_ease(Tween.EASE_OUT)
	Globals.update_player_hp(damage_taken)

func flip() -> void:
	if $SpriteRoot.scale.x > 0:
		$SpriteRoot.scale.x *= -1

func unflip() -> void:
	if $SpriteRoot.scale.x < 0:
		$SpriteRoot.scale.x *= -1

func _on_hit_flash_timer_timeout() -> void:
	$SpriteRoot.material.set_shader_parameter('progress',0)



func _push_units():
	for body in unit_collision_push_array:
		if body.get_ref().state_machine.state != body.get_ref().state_machine.states.idle:
			continue
		if body.get_ref().state_machine.command == body.get_ref().state_machine.commands.HOLD:
			continue
			#ta liczba oznacza jak daleko ma sie odsunac odepchnieta jednostka
		if angle_difference(global_position.angle_to_point(global_position+direction), global_position.angle_to_point(body.get_ref().global_position)) < PI/2:
			body.get_ref().move_target = body.get_ref().global_position + (global_position.direction_to(body.get_ref().global_position) * 50)
			body.get_ref().state_machine.set_state(body.get_ref().state_machine.states.moving)
			
func push_units():
	for body in unit_collision_push_array:
		if body.get_ref().state_machine.state != body.get_ref().state_machine.states.idle:
			continue
		if body.get_ref().state_machine.command == body.get_ref().state_machine.commands.HOLD:
			continue
			#ta liczba oznacza jak daleko ma sie odsunac odepchnieta jednostka
		if angle_difference(global_position.angle_to_point(global_position+direction), global_position.angle_to_point(body.get_ref().global_position)) < PI/2:
			body.get_ref().move_target = body.get_ref().global_position + (global_position.direction_to(body.get_ref().global_position) * 50)
			body.get_ref().state_machine.set_state(body.get_ref().state_machine.states.moving)
			#body.get_ref().push_units()

func _on_movement_push_area_body_entered(body: Node2D) -> void:
	unit_collision_push_array.append(weakref(body))

func _on_movement_push_area_body_exited(body: Node2D) -> void:
	for unit in unit_collision_push_array:
		if unit.get_ref() == body:
			unit_collision_push_array.erase(unit)
