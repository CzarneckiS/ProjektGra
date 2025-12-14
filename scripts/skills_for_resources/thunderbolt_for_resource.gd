extends SkillInstant
class_name Thunderbolt

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var skill_effect_data: EffectDamage
@export var skill_effect_data2: EffectAreaOfEffect
@export var skill_effect_data3: EffectKnockback

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(target_position, self)
