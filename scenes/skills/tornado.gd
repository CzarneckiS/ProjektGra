extends Area2D
class_name TornadoSpell

var skill_resource: Tornado
var lifespan: Timer = Timer.new()
var ticks_per_sec: Timer = Timer.new()
var get_new_direction_cooldown: Timer = Timer.new()
var transformation_thunderbolt_timer: Timer = Timer.new()
var transformation_heal_timer: Timer = Timer.new()
var orb_spawn_timer: Timer = Timer.new()
var is_ticking: bool = false
var transformed: bool = false
var target_position: Vector2
var spawn_center: Vector2
var thunderbolt_skill: Resource = preload("res://resources/thunderbolt_for_tornado.tres")
var heal_skill: Resource = preload("res://resources/heal_for_tornado.tres")
var fireball_skill: Resource = preload("res://resources/fireball_for_tornado.tres")
var tornado_mini_skill: Resource = preload("res://resources/tornado_mini.tres")
var orb_skill: Resource = preload("res://resources/orb.tres")

var base_damage
var damage_multiplier

@onready var tornado_collision_pull_area: Area2D = $tornado_collision_pull_area
@onready var tornado_collision_pull: CollisionShape2D = $tornado_collision_pull_area/tornado_collision_pull
@onready var tornado_collision_knockback_area: Area2D = $tornado_collision_knockback_area
@onready var tornado_collision_knockback: CollisionShape2D = $tornado_collision_knockback_area/tornado_collision_knockback
@onready var tornado_collision_transform_area: Area2D = $tornado_collision_transform_area
@onready var tornado_collision_transform: CollisionShape2D = $tornado_collision_transform_area/tornado_collision_transform
@onready var tornado_animation: AnimationPlayer = $tornado_animation
@onready var tornado_collision_heal_area: Area2D = $tornado_collision_heal_area
@onready var tornado_collision_heal: CollisionShape2D = $tornado_collision_heal_area/tornado_collision_heal
@onready var tornado_collision_heal_protection_area: Area2D = $tornado_collision_heal_protection_area
@onready var tornado_collision_heal_protection: CollisionShape2D = $tornado_collision_heal_protection_area/tornado_collision_heal_protection
@onready var tornado_heal_protection_animation: AnimatedSprite2D = $tornado_collision_heal_protection_area/tornado_heal_protection_animation
@onready var tornado_collision_iceblock_slow: CollisionShape2D = $tornado_collision_iceblock_slow_area/tornado_collision_iceblock_slow
@onready var tornado_collision_iceblock_slow_area: Area2D = $tornado_collision_iceblock_slow_area
@onready var tornado_collision_iceblock_slow_area_animation: AnimatedSprite2D = $tornado_collision_iceblock_slow_area/tornado_collision_iceblock_slow_area_animation

func initialize(spawn_position: Vector2, skill_res: Tornado):
	skill_resource = skill_res.duplicate(true)
	base_damage = skill_resource.effect_dot.damage_per_tick
	damage_multiplier = skill_resource.effect_dot.damage_multiplier
	
	global_position = spawn_position
	spawn_center = spawn_position
	target_position = spawn_center + _get_new_direction()
	
	add_child(lifespan)
	lifespan.one_shot = true
	lifespan.autostart = false
	lifespan.wait_time = skill_resource.effect_dot.duration
	lifespan.timeout.connect(_on_lifespan_timeout)
	
	add_child(ticks_per_sec)
	ticks_per_sec.one_shot = false
	ticks_per_sec.autostart = false
	ticks_per_sec.wait_time = 1.0/skill_resource.effect_dot.ticks_per_second
	ticks_per_sec.timeout.connect(_on_ticks_per_sec_timeout)
	
	add_child(get_new_direction_cooldown)
	get_new_direction_cooldown.one_shot = true
	get_new_direction_cooldown.autostart = false
	get_new_direction_cooldown.wait_time = skill_resource.time_before_new_direction
	get_new_direction_cooldown.timeout.connect(_on_get_new_direction_cooldown_timeout)
	
	add_child(transformation_thunderbolt_timer)
	transformation_thunderbolt_timer.one_shot = false
	transformation_thunderbolt_timer.autostart = true
	transformation_thunderbolt_timer.wait_time = skill_resource.transformation_thunderbolt_frequency
	transformation_thunderbolt_timer.timeout.connect(_on_transformation_thunderbolt_timer_timeout)
	
	add_child(transformation_heal_timer)
	transformation_heal_timer.one_shot = false
	transformation_heal_timer.autostart = true
	transformation_heal_timer.wait_time = skill_resource.transformation_heal_frequency
	transformation_heal_timer.timeout.connect(_on_transformation_heal_timer_timeout)
	
	add_child(orb_spawn_timer)
	orb_spawn_timer.one_shot = false
	orb_spawn_timer.autostart = true
	orb_spawn_timer.wait_time = 1.0/skill_resource.orb_spawn_frequency
	orb_spawn_timer.timeout.connect(_on_transformation_orb_spawn_timer_timeout)
	
	if skill_resource.effect_aoe != null:
		if tornado_collision_pull.shape:
			var base_radius = skill_resource.effect_aoe.radius
			var shape_duplicate = tornado_collision_pull.shape.duplicate()
			tornado_collision_pull.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.effect_aoe.radius_multiplier
	
func _ready():
	lifespan.call_deferred("start")
	$tornado_sprite.animation_finished.connect(_on_tornado_animation_finished)
	$tornado_sprite.play("on_creation")
	tornado_animation.play("default")
	tornado_collision_pull_area.body_entered.connect(_on_tornado_collision_pull_entered)
	tornado_collision_transform_area.area_entered.connect(transform_skill)
	tornado_collision_knockback_area.body_entered.connect(_on_tornado_collision_knockback_entered)
	tornado_collision_heal_protection_area.area_entered.connect(_on_tornado_collision_heal_protection_area_entered)
	tornado_collision_iceblock_slow_area.body_entered.connect(_on_tornado_collision_iceblock_slow_area_entered)
	tornado_collision_iceblock_slow_area.body_exited.connect(_on_tornado_collision_iceblock_slow_area_exited)
	$tornado_sfx.play()
	
func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_ticks_per_sec_timeout():
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for body in overlapping_bodies:
			if !body.is_in_group("Allied") and body.has_method("hit"):
				body.hit(base_damage * damage_multiplier, self)
	else:
		ticks_per_sec.stop()
		is_ticking = false

func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
	
	global_position = global_position.move_toward(target_position, skill_resource.speed*delta)
	if global_position.distance_to(target_position) < 5.0:
		if get_new_direction_cooldown.is_stopped():
			get_new_direction_cooldown.start()
		
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty() and !is_ticking:
		ticks_per_sec.call_deferred("start")
		is_ticking = true
		
func _on_tornado_collision_pull_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		skill_resource.effect_pull.apply_push(global_position, body)

func transform_skill(skill):
	if transformed:
		return
	match skill:
		_ when skill is FireballSpell:
			transform_animation(Color("00ce8dff"))
			transformation_fireball()
		_ when skill is ThunderboltSpell:
			transform_animation(Color("7cfffeff"))
			transformation_thunderbolt()
		_ when skill is HealSpell:
			transform_animation(Color("ca57ffff"))
			transformation_heal()
		_ when skill.owner is IceblockSpell:
			transform_animation(Color("5ec9ffff"))
			transformation_iceblock(skill)
		_ when skill is FieldSpell:
			transform_animation(Color("181528ff"))
			transformation_field(skill)
		_ :
			return
	transformed = true

func transform_animation(color: Color):
	var transform_color: Color = Color.WHITE
	var transform_tween = create_tween()
	
	transform_color = Color(color) * 2.0
	transform_tween.tween_property($tornado_sprite, "modulate", transform_color, 0.35)
	transform_tween.set_ease(Tween.EASE_OUT)
	
func _get_new_direction() -> Vector2:
	var radius = skill_resource.range_radius
	var angle = randf() * TAU
	var distance = sqrt(randf()) * radius
	return Vector2(cos(angle), sin(angle)) * distance

func _on_get_new_direction_cooldown_timeout():
	target_position = spawn_center + _get_new_direction()

func transformation_fireball():
	var amount = fireball_skill.amount
	for i in range(amount):
		var shift = (TAU/amount) * i
		fireball_skill.call_deferred("use", self, Vector2.ZERO, shift)

func transformation_thunderbolt():
	transformation_thunderbolt_timer.start()
	
func _on_transformation_thunderbolt_timer_timeout():
	thunderbolt_skill.call_deferred("use", self, global_position)
	
func transformation_heal():
	skill_resource.effect_pull.pull_friction = 0
	skill_resource.effect_pull.pull_speed = 0
	skill_resource.effect_knockback.knockback_friction = 4.5
	skill_resource.effect_knockback.knockback_speed = 1800
	
	tornado_collision_heal_protection.set_deferred("disabled", false)
	tornado_heal_protection_animation.play("protection")
	
	transformation_heal_timer.start()

func _on_transformation_heal_timer_timeout():
	var overlapping_bodies = tornado_collision_heal_area.get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for body in overlapping_bodies:
			if body.is_in_group("Allied") and body is UnitParent:
				heal_skill.call_deferred("use", self, global_position)
func _on_tornado_collision_knockback_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		skill_resource.effect_knockback.apply_push(global_position, body)

func _on_tornado_collision_heal_protection_area_entered(projectile):
	if projectile.is_in_group("EnemyProjectile"):
		projectile.call_deferred("queue_free")

func transformation_iceblock(skill):
	skill.owner.call_deferred("queue_free")
	tornado_collision_iceblock_slow.set_deferred("disabled", false)
	tornado_collision_iceblock_slow_area_animation.play("slow_area")
	skill_resource.effect_pull.pull_friction = 0
	skill_resource.effect_pull.pull_speed = 0
	skill_resource.effect_knockback.knockback_speed = 0
	skill_resource.effect_knockback.knockback_friction = 0
	self.scale *= 2.5
	damage_multiplier += 0.2
	base_damage += 5
	
func _on_tornado_collision_iceblock_slow_area_entered(body):
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for bodies in overlapping_bodies:
			if !bodies.is_in_group("Allied"):
				body.speed = body.default_speed - 100

func _on_tornado_collision_iceblock_slow_area_exited(body):
	body.speed = body.default_speed

func transformation_field(_skill):
	orb_spawn_timer.start()
	var amount = tornado_mini_skill.amount
	for orb in range(amount):
		tornado_mini_skill.call_deferred("use", self, global_position)

func _on_transformation_orb_spawn_timer_timeout():
	orb_skill.call_deferred("use", self, global_position)

func _on_tornado_animation_finished():
	if $tornado_sprite.animation == "on_creation":
		$tornado_sprite.play("default")
