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
func upgrade_skill():
	skill_effect_data.base_heal = 10 + (5*skill_level)
	skill_effect_data2.radius = 150.0 + (10.0*skill_level)
	cooldown = 6 - (0.3*skill_level)
func get_desc() -> String:
	if skill_level > 0:
		return "[b][color=#dbc4a6]heal your units in an area[/color][/b]\n\n[table=2][cell]heal: [/cell][cell]%s[/cell]\n[cell]heal multiplier: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]radius multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_heal+5, skill_effect_data.heal_multiplier, skill_effect_data2.radius+10.0, skill_effect_data2.radius_multiplier, cooldown-0.3, skill_level]
	return "[b][color=#dbc4a6]heal your units in an area[/color][/b]\n\n[table=2][cell]heal: [/cell][cell]%s[/cell]\n[cell]heal multiplier: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]radius multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_heal, skill_effect_data.heal_multiplier, skill_effect_data2.radius, skill_effect_data2.radius_multiplier, cooldown, skill_level]
