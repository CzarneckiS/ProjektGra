extends Skill
class_name PlayerSkeletonMage


@export var tags : Dictionary = {}
func use(player: CharacterBody2D):
	player.skeleton_mage_count = skill_level
func _init() -> void:
	tags["Player"] = tags.size()
