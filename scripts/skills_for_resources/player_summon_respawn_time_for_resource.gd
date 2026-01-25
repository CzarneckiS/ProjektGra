extends Skill
class_name PlayerSummonRespawnTimeUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D):
	player.summon_respawn_timer_modifier = (0.5 + 0.5/((skill_level+1)+1))
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "[b][color=#dbc4a6]if your units die they come back faster[/color][/b]\n\n[table=2][cell]respawn timer: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[str(5 * snappedf((0.5 + 0.5/((skill_level+1)+1)), 0.01)), skill_level]

func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]if your units die they come back faster[/color][/b]\n\n[table=2][cell]respawn timer: [/cell][cell]%s[/cell][/table]" \
 %[str(5 * snappedf((0.5 + 0.5/((skill_level+1)+1)), 0.01))]

func tooltip_desc():
	return "[b][color=#dbc4a6]if your units die they come back faster[/color][/b]\n\n[table=2][cell]respawn timer: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[str(5 * snappedf((0.5 + 0.5/((skill_level)+1)), 0.01)), skill_level]
