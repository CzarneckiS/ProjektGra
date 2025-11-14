extends Skill
class_name PlayerSkeletonWarrior


@export var tags : Dictionary = {}
func use(player: CharacterBody2D):
	player.skeleton_warrior_count = skill_level
func _init() -> void:
	tags["Player"] = tags.size()
