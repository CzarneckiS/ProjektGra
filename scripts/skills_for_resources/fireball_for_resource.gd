extends SkillRangeBased
class_name Fireball

@export var skill_effect_data: EffectDamage
@export var effect_knockback: EffectKnockback
@export var amount: int
@export var offset: Vector2

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player, target_position: Vector2, shift: float = 0.0) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(player, target_position, self, shift)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func get_desc() -> String:
	return "cast a single projectile in a straight line\n\ndamage: %s\ndamage multiplier: %s\ncooldown: %s\nskill level: %s" \
 %[skill_effect_data.base_damage, skill_effect_data.damage_multiplier, cooldown, skill_level]
