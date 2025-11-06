extends Node2D
class_name SkeletonMageProjectileSpell

var skill_resource: SkeletonMageProjectile

var start_position: Vector2
var direction: Vector2
var target
var target_position
var collision_distance = 20
func initialize(unit: CharacterBody2D, _target: CharacterBody2D, skill_res: SkeletonMageProjectile):
	skill_resource = skill_res
	target = _target
	global_position = unit.global_position


func _ready():
	$AnimatedSprite2D.modulate = Color(0.867, 0.326, 0.364, 1.0)
	$AnimatedSprite2D.connect("animation_finished", _on_animated_sprite_2d_animation_finished)
	$AnimatedSprite2D.play("on_creation")
	
func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
	if target:
		target_position = target.global_position
	direction = (target_position - global_position).normalized()
	look_at(target_position)
	global_position += direction * skill_resource.speed * delta

	if (global_position.distance_to(target_position) <= collision_distance):
		if target:
			target.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
		queue_free()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("flying")
