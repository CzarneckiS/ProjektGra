extends SkillInstant
class_name Thunderbolt

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var skill_effect_data: EffectDamage
@export var skill_effect_data2: EffectAreaOfEffect
@export var skill_effect_data3: EffectKnockback

func use(player, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func upgrade_skill():
	skill_effect_data.base_damage = 20+(7*skill_level)
	skill_effect_data2.radius = 200.0+(10.0*skill_level)
	cooldown = 6 - (0.4 * skill_level)
func get_desc() -> String:
	if skill_level > 0:
		return "[b][color=#dbc4a6]strike the designated point[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage+7, skill_effect_data2.radius+10.0, cooldown-0.5, skill_level]
	return "[b][color=#dbc4a6]strike the designated point[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage, skill_effect_data2.radius, cooldown, skill_level]

func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]strike the designated point[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage, skill_effect_data2.radius, cooldown]

func tooltip_desc():
	return "[b][color=#dbc4a6]strike the designated point[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage, skill_effect_data2.radius, cooldown, skill_level]
