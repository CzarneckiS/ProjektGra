extends Skill
class_name SkillTarget

func use(_player: CharacterBody2D, target: UnitParent) -> void:
	print("SkillTarget use() invoked.")
	for effect in effects:
		effect.apply(target)
