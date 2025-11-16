extends Skill
class_name PlayerSkeletonWarrior


@export var tags : Dictionary = {}
func use(player: CharacterBody2D):
	player.skeleton_warrior_count = skill_level
	player.summon_unit.emit("SkeletonWarrior")
func _init() -> void:
	tags["Player"] = tags.size()
	tags["Summon"] = tags.size()
