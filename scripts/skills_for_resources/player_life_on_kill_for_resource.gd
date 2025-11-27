extends SkillInstant
class_name PlayerLifeOnKill

@export var skill_effect_data: EffectDamage
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	target.hit(100, unit)
func _init() -> void:
	pass
