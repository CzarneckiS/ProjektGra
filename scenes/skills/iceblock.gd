extends Area2D
class_name IceblockSpell

var skill_resource: Iceblock
var lifespan: Timer = Timer.new()

func initialize(spawn_position: Vector2, skill_res: Iceblock):
	skill_resource = skill_res
	
	global_position = spawn_position
	
	add_child(lifespan)
	lifespan.one_shot = true
	lifespan.autostart = false
	lifespan.wait_time = 2.0
	lifespan.timeout.connect(_on_lifespan_timeout)
	
	#if skill_resource.skill_effect_data2 != null:
		#if $iceblock_collision.shape:
			#var base_radius = skill_resource.skill_effect_data2.radius
			#var shape_duplicate = $iceblock_collision.shape.duplicate()
			#$iceblock_collision.shape = shape_duplicate
			#
			#shape_duplicate.radius = base_radius * skill_resource.skill_effect_data2.radius_multiplier
	
func _ready():
	lifespan.call_deferred("start")
	
	$iceblock_animation.play("ice_wall_diagonal")
	body_entered.connect(_on_body_entered)

func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_body_entered(body):
	if !body.is_in_group("Allied"):
		body.hit(skill_resource.effect_damage.base_damage*skill_resource.effect_damage.damage_multiplier, self)
