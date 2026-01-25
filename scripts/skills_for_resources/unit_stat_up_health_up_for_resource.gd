extends Skill
class_name UnitStatUpHealthUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var damage_bonus : int = 15
func use(unit: CharacterBody2D):
	unit.max_health = unit.base_max_health + skill_level * 20
	unit.health_bar.max_value = unit.max_health
	unit.damage_bar.max_value = unit.max_health
	unit.heal(skill_level * 20)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "[b][color=#dbc4a6]bones of your units are sturdier[/color][/b]\n\n[table=2][cell]unit health: [/cell][cell]+%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell]" \
 %[(skill_level+1) * 20, skill_level]
func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]bones of your units are sturdier[/color][/b]\n\n[table=2][cell]unit health: [/cell][cell]+%s[/cell]" \
 %[(skill_level+1) * 20]

func tooltip_desc():
	return "[b][color=#dbc4a6]bones of your units are sturdier[/color][/b]\n\n[table=2][cell]unit health: [/cell][cell]+%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell]" \
 %[(skill_level) * 20, skill_level]
