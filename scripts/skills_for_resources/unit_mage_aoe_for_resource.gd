extends SkillInstant
class_name UnitMageAOE

@export var skill_effect_data: EffectDamage
@export var tags : Dictionary = {}
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	target.hit(100, unit)
func _init() -> void:
	tags["SkeletonWarrior"] = tags.size()
	tags["OnHit"] = tags.size()
