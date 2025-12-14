extends SkillInstant
class_name Field

@export var push_effect: EffectPull
@export var aoe_effect: EffectAreaOfEffect
@export var dot_effect: EffectDamageOverTime

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(target_position, self)
