extends SkillRangeBased
class_name Fireball

@export var skill_effect_data: EffectDamage

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(player.global_position, target_position, self)
