extends Skill
class_name PlayerSkeletonMage


@export var tags : Dictionary = {}
func use(player: CharacterBody2D):
	player.skeleton_mage_count = skill_level
	player.summon_unit.emit("SkeletonMage")
func _init() -> void:
	tags["Player"] = tags.size()
	tags["Summon"] = tags.size()
