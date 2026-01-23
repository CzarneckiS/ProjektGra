extends SkillInstantAllied
class_name Heal

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var skill_effect_data: EffectHeal
@export var skill_effect_data2: EffectAreaOfEffect

func use(player, _target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(player, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func get_desc() -> String:
	return "heal your units in an area\n\nheal: %s\nheal multiplier: %s\nradius: %s\nradius multiplier: %s\ncooldown: %s\nskill level: %s" \
 %[skill_effect_data.base_heal, skill_effect_data.heal_multiplier, skill_effect_data2.radius, skill_effect_data2.radius_multiplier, cooldown, skill_level]
