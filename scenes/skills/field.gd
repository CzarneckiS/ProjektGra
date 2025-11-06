extends Area2D
class_name FieldSpell

var skill_resource: Field
var lifespan: Timer = Timer.new()
var ticks_per_sec: Timer = Timer.new()
var is_ticking: bool = false

func initialize(spawn_position: Vector2, skill_res: Field):
	skill_resource = skill_res
	
	global_position = spawn_position
	
	add_child(lifespan)
	lifespan.one_shot = true
	lifespan.autostart = false
	lifespan.wait_time = skill_resource.dot_effect.duration
	lifespan.timeout.connect(_on_lifespan_timeout)
	
	add_child(ticks_per_sec)
	ticks_per_sec.one_shot = false
	ticks_per_sec.autostart = false
	ticks_per_sec.wait_time = 1.0/skill_resource.dot_effect.ticks_per_second
	ticks_per_sec.timeout.connect(_on_ticks_per_sec_timeout)
	
	if skill_resource.aoe_effect != null:
		if $field_collision.shape:
			var base_radius = skill_resource.aoe_effect.radius
			var shape_duplicate = $field_collision.shape.duplicate()
			$field_collision.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.aoe_effect.radius_multiplier
	
func _ready():
	lifespan.call_deferred("start")
	
	$field_animation.play("default")
	$field_animation.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)

func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_animation_finished():
	$field_animation.play("attack")	
	
func _on_ticks_per_sec_timeout():
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for body in overlapping_bodies:
			if !body.is_in_group("Allied"):
				body.hit(skill_resource.dot_effect.damage_per_tick * skill_resource.dot_effect.damage_multiplier, self)
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

func _on_body_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		skill_resource.push_effect.apply_push(global_position, body)
