extends Area2D
class_name IceblockSpell

var skill_resource: Iceblock
var lifespan: Timer = Timer.new()
var ticks_per_sec: Timer = Timer.new()
var is_ticking: bool = false

func initialize(spawn_position: Vector2, skill_res: Iceblock):
	skill_resource = skill_res
	
	global_position = spawn_position
	
	add_child(lifespan)
	lifespan.one_shot = true
	lifespan.autostart = false
	lifespan.wait_time = skill_resource.skill_effect_data3.duration
	lifespan.timeout.connect(_on_lifespan_timeout)
	
	add_child(ticks_per_sec)
	ticks_per_sec.one_shot = false
	ticks_per_sec.autostart = false
	ticks_per_sec.wait_time = 1.0/skill_resource.skill_effect_data3.ticks_per_second
	ticks_per_sec.timeout.connect(_on_ticks_per_sec_timeout)
	
	if skill_resource.skill_effect_data2 != null:
		if $iceblock_collision.shape:
			var base_radius = skill_resource.skill_effect_data2.radius
			var shape_duplicate = $iceblock_collision.shape.duplicate()
			$iceblock_collision.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.skill_effect_data2.radius_multiplier
	
func _ready():
	lifespan.call_deferred("start")
	
	$iceblock_animation.play("default")
	body_entered.connect(_on_body_entered)

func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_ticks_per_sec_timeout():
	var overlapping_bodies = get_overlapping_bodies()
	if !overlapping_bodies.is_empty():
		for body in overlapping_bodies:
			if !body.is_in_group("Allied"):
				body.hit(skill_resource.skill_effect_data3.damage_per_tick * skill_resource.skill_effect_data3.damage_multiplier, self)
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
		
func _on_body_entered(body):
	if !body.is_in_group("Allied"):
		body.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
