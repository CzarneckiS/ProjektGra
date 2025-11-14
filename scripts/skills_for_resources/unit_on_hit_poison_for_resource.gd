extends SkillInstant
class_name UnitOnHitPoison

@export var skill_effect_data: EffectDamage
@export var tags : Dictionary = {}
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	target.hit(100, unit)
	print(tags)
func _init() -> void:
	tags["SkeletonWarrior"] = tags.size()
	tags["OnHit"] = tags.size()
