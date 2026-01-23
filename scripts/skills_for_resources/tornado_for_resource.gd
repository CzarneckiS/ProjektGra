extends SkillInstant
class_name Tornado

#@export var effect_damage: EffectDamage
@export var effect_aoe: EffectAreaOfEffect
@export var effect_dot: EffectDamageOverTime
@export var effect_pull: EffectPull
@export var effect_knockback: EffectKnockback
@export var range_radius: float
@export var speed: float
@export var time_before_new_direction: float
@export var transformation_thunderbolt_frequency: float
@export var transformation_heal_frequency: float
@export var effect_heal: EffectHeal
@export var amount: int
@export var orb_spawn_frequency: int
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)

func get_desc() -> String:
	return "other spells can bring its full potential\n\ndamage per second: %s\ndamage multiplier: %s\nduration: %s\ncooldown: %s\nskill level: %s" \
 %[effect_dot.damage_per_tick*effect_dot.ticks_per_second, effect_dot.damage_multiplier, effect_dot.duration, cooldown, skill_level]
