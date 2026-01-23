extends SkillInstant
class_name Iceblock

@export var effect_damage: EffectDamage
@export var effect_knockback: EffectKnockback
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []

func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func get_desc() -> String:
	return "block the enemy path\n\ndamage: %s\ndamage multiplier: %s\ncooldown: %s\nskill level: %s" \
 %[effect_damage.base_damage, effect_damage.damage_multiplier, cooldown, skill_level]
