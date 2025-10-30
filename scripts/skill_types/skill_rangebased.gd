extends Skill
class_name SkillRangeBased

@export var max_range : float = 250.0

func use(_player: CharacterBody2D, target: UnitParent) -> void:
	print("SkillRangeBased use() invoked.")
	for effect in effects:
		effect.apply(target)
