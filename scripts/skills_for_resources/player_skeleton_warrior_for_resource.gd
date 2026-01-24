extends Skill
class_name PlayerSkeletonWarrior


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D):
	player.skeleton_warrior_count = skill_level
	player.summon_unit.emit("SkeletonWarrior")
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.SUMMON)
func get_desc() -> String:
	return "[b][color=#dbc4a6]Raise the warrior from the dead[/color][/b]"
