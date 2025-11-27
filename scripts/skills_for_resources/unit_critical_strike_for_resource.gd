extends SkillInstant
class_name UnitCriticalStrike

@export var skill_effect_data: EffectDamage
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	target.hit(100, unit)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.SKELETON_WARRIOR)
	use_tags.append(Tags.UseTag.PASSIVE)
