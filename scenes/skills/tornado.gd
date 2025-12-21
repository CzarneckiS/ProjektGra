extends Area2D
class_name TornadoSpell

var skill_resource: Tornado
var lifespan: Timer = Timer.new()
var ticks_per_sec: Timer = Timer.new()
var is_ticking: bool = false

var base_damage
var damage_multiplier

@onready var tornado_collision_pull_area: Area2D = $tornado_collision_pull_area
@onready var tornado_collision_pull: CollisionShape2D = $tornado_collision_pull_area/tornado_collision_pull
@onready var tornado_collision_transform_area: Area2D = $tornado_collision_transform_area
@onready var tornado_collision_transform: CollisionShape2D = $tornado_collision_transform_area/tornado_collision_transform
@onready var tornado_animation: AnimationPlayer = $tornado_animation

func initialize(spawn_position: Vector2, skill_res: Tornado):
	skill_resource = skill_res
	base_damage = skill_resource.effect_dot.damage_per_tick
	damage_multiplier = skill_resource.effect_dot.damage_multiplier
	
	global_position = spawn_position
	
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
	
	if skill_resource.effect_aoe != null:
		if tornado_collision_pull.shape:
			var base_radius = skill_resource.effect_aoe.radius
			var shape_duplicate = tornado_collision_pull.shape.duplicate()
			tornado_collision_pull.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.effect_aoe.radius_multiplier
	
func _ready():
	lifespan.call_deferred("start")
	
	tornado_animation.play("default")
	tornado_collision_pull_area.body_entered.connect(_on_tornado_collision_pull_entered)
	tornado_collision_transform_area.area_entered.connect(transform_skill)
	
func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_ticks_per_sec_timeout():
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for body in overlapping_bodies:
			if !body.is_in_group("Allied"):
				body.hit(base_damage * damage_multiplier, self)
	else:
		ticks_per_sec.stop()
		is_ticking = false

func _physics_process(_delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
		
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty() and !is_ticking:
		ticks_per_sec.call_deferred("start")
		is_ticking = true
		
func _on_tornado_collision_pull_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		skill_resource.effect_pull.apply_push(global_position, body)

func _on_tornado_collision_transform_entered(body):
	if body is FireballSpell:
		tornado_animation.play("fireballed")
	elif body is ThunderboltSpell:
		tornado_animation.play("thunderbolted")
	else:
		return

func transform_skill(skill):
	match skill.name:
		"fireball":
			transform_animation("006626ff")
			ticks_per_sec.wait_time = 1.0/20.0
			base_damage = 6
		"thunderbolt":
			transform_animation("00ffffff")
			base_damage = -100

func transform_animation(color: String):
	var transform_color: Color = Color.WHITE
	var transform_tween = create_tween()
	
	transform_color = Color(color) * 5.0
	transform_tween.tween_property($tornado_sprite, "modulate", transform_color, 0.35)
	transform_tween.set_ease(Tween.EASE_OUT)
