extends SkillInstant
class_name Thunderbolt

@export var tags : Dictionary = {}
@export var skill_effect_data: EffectDamage
@export var skill_effect_data2: EffectAreaOfEffect

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(target_position, self)
