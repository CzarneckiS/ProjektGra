extends SkillInstant
class_name Iceblock

@export var skill_effect_data: EffectDamage
@export var skill_effect_data2: EffectAreaOfEffect
@export var skill_effect_data3: EffectDamageOverTime

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(target_position, self)
