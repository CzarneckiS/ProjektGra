extends Skill
class_name UnitStatUpAttackUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var damage_bonus : int = 15
func use(unit: CharacterBody2D):
	unit.damage = unit.base_damage + (damage_bonus * skill_level)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "[b][color=#dbc4a6]your units hit harder[/color][/b]\n\n[table=2][cell]unit damage: [/cell][cell]+%s[/cell]\n[cell]skill level: %s[/cell][/table]" \
 %[damage_bonus * (skill_level+1), skill_level]
func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]your units hit harder[/color][/b]\n\n[table=2][cell]unit damage: [/cell][cell]+%s[/cell][/table]" \
 %[damage_bonus * (skill_level+1)]

func tooltip_desc():
	return "[b][color=#dbc4a6]your units hit harder[/color][/b]\n\n[table=2][cell]unit damage: [/cell][cell]+%s[/cell]\n[cell]skill level: %s[/cell][/table]" \
 %[damage_bonus * (skill_level), skill_level]
