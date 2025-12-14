extends Area2D
class_name HumanMageProjectileScene

var skill_resource

var start_position: Vector2
var direction: Vector2
var target
var target_position
var collision_distance = 20
var parent_unit
var damage
func initialize(unit: CharacterBody2D, _target: CharacterBody2D, skill_res):
	skill_resource = skill_res
	target = _target
	start_position = unit.global_position
	global_position = start_position
	parent_unit = unit
	damage = parent_unit.damage
	target_position = target.global_position
	direction = (target_position - start_position).normalized()
	look_at(target_position)


func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.connect("animation_finished", _on_animated_sprite_2d_animation_finished)
	$AnimatedSprite2D.play("on_creation")
	
func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return

	global_position += direction * skill_resource.speed * delta
	if start_position.distance_to(global_position) >= skill_resource.max_range:
		queue_free()

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("Allied"):
		body.hit(damage, self)

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("flying")
