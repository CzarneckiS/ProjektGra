extends Skill
class_name PlayerSkeletonMage


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D):
	player.skeleton_mage_count = skill_level
	player.summon_unit.emit("SkeletonMage")
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.SUMMON)
func get_desc() -> String:
	return "Raise the mage from the dead"
