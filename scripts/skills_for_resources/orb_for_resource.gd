extends SkillInstant
class_name Orb

@export var skill_effect_data: EffectDamage
@export var effect_knockback: EffectKnockback
@export var effect_heal: EffectHeal
@export var effect_aoe: EffectAreaOfEffect
@export var give_exp_amount: float

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(player, target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
