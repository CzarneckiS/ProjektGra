extends SkillInstant
class_name UnitUnholyFrenzy

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var attack_speed_multiplier = 0.15
func use(unit: CharacterBody2D) -> void:
	unit.attack_speed_modifier = 1 + attack_speed_multiplier * skill_level
	var unholy_frenzy_status_effect = UnholyFrenzyStatusEffect.new()
	unholy_frenzy_status_effect.initialize(unit)
	var unholy_frenzy_visual_effects = visual_effect.instantiate()
	unit.find_child("Head").add_child(unholy_frenzy_visual_effects)
	unholy_frenzy_visual_effects.show_behind_parent = true
	unholy_frenzy_visual_effects.play("default")
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.PASSIVE)
func get_desc() -> String:
	return "[b][color=#dbc4a6]your units gain attack speed but they're slowly dying[/color][/b]\n\n[table=2][cell]attack speed multiplier: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" %[(1 + attack_speed_multiplier * (skill_level+1)), skill_level]
func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]your units gain attack speed but they're slowly dying[/color][/b]\n\n[table=2][cell]attack speed multiplier: [/cell][cell]%s[/cell][/table]" %[(1 + attack_speed_multiplier * (skill_level+1))]
