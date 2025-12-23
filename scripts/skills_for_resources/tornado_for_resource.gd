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

func use(player, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
