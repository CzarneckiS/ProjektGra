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
func upgrade_skill():
	effect_dot.damage_per_tick = 2+skill_level
	effect_dot.ticks_per_second = 3 + (0.5*skill_level)
	effect_dot.damage_multiplier = 1.0 + (0.05*skill_level)
	effect_dot.duration = 4+(1.2*skill_level)
	cooldown = 14 - (0.5*skill_level)
func get_desc() -> String:
	if skill_level > 0:
		return "[b][color=#dbc4a6]other spells can bring its full potential[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(effect_dot.damage_per_tick+skill_level)*(effect_dot.ticks_per_second+0.5)*(effect_dot.damage_multiplier+0.05), effect_dot.duration+1.2, cooldown-0.5, skill_level]
	return "[b][color=#dbc4a6]other spells can bring its full potential[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[effect_dot.damage_per_tick*effect_dot.ticks_per_second, effect_dot.duration, cooldown, skill_level]

func get_skill_name() -> String:
	return "[wave amp=20.0 freq=8.0 connected=0][rainbow freq=2.0 sat=0.4 val=1.0 speed=0.5]Whirlwind[/rainbow][/wave]"

func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]other spells can bring its full potential[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell][/table]" \
 %[effect_dot.damage_per_tick*effect_dot.ticks_per_second, effect_dot.duration, cooldown]
