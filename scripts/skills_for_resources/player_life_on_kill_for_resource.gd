extends SkillInstant
class_name PlayerLifeOnKill

@export var skill_effect_data: EffectDamage
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D) -> void:
	player.heal(skill_level * 2)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.UNIT_DEATH)
func get_desc() -> String:
	return "[b][color=#dbc4a6]heal yourself by killing[/color][/b]\n\n[table=2][cell]heal per kill: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" %[(skill_level+1)*2, skill_level]
func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]heal yourself by killing[/color][/b]\n\n[table=2][cell]heal per kill: [/cell][cell]%s[/cell][/table]" %[(skill_level+1)*2]
