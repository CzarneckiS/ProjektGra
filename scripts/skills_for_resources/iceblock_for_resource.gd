extends SkillInstant
class_name Iceblock

@export var effect_damage: EffectDamage
@export var effect_knockback: EffectKnockback

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(target_position, self)
