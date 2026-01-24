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
	times_upgraded += 1
	print("ile razy ulepszono: ", times_upgraded)
	effect_dot.damage_per_tick += 2
	effect_aoe.radius += 10.0
	if times_upgraded == 2:
		transformation_thunderbolt_frequency += 1
		transformation_heal_frequency += 1
		effect_heal.base_heal += 2
		amount += 1
		orb_spawn_frequency += 1
		cooldown -= 0.2
	if times_upgraded == 4:
		transformation_thunderbolt_frequency += 1
		transformation_heal_frequency += 1
		effect_heal.base_heal += 2
		amount += 1
		orb_spawn_frequency += 1
	if times_upgraded == 6:
		transformation_thunderbolt_frequency += 2
		transformation_heal_frequency += 2
		effect_heal.base_heal += 5
		amount += 2
		orb_spawn_frequency += 2
	
func get_desc() -> String:
	return "[b][color=#dbc4a6]other spells can bring its full potential[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[effect_dot.damage_per_tick*effect_dot.ticks_per_second, effect_dot.damage_multiplier, effect_dot.duration, cooldown, skill_level]
