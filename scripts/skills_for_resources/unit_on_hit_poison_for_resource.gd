extends SkillInstant
class_name UnitOnHitPoison

@export var hit_amount: int = 5
@export var skill_effect_data: EffectDamage
@export var damage_interval: float = 0.5
@export var tags: Dictionary = {}
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var poison_status_effect = PoisonStatusEffect.new()
	poison_status_effect.initialize(unit, target, damage_interval, skill_effect_data.base_damage, hit_amount)
func _init() -> void:
	tags["SkeletonWarrior"] = tags.size()
	tags["OnHit"] = tags.size()
