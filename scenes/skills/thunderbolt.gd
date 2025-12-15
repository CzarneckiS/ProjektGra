extends Area2D
class_name ThunderboltSpell

var skill_resource: Thunderbolt

func initialize(spawn_position: Vector2, skill_res: Thunderbolt):
	skill_resource = skill_res
	
	global_position = spawn_position
	
	if skill_resource.skill_effect_data2 != null:
		if $thunderbolt_collision.shape:
			var base_radius = skill_resource.skill_effect_data2.radius
			var shape_duplicate = $thunderbolt_collision.shape.duplicate()
			$thunderbolt_collision.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.skill_effect_data2.radius_multiplier
	
func _ready():
	$thunderbolt_animation.play("default")
	$thunderbolt_animation.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	
func _on_animation_finished():
	call_deferred("queue_free")
	
func _physics_process(_delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return

func _on_body_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		body.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
		skill_resource.skill_effect_data3.apply_push(global_position, body)
