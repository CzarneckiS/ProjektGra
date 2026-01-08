extends SkillInstant
class_name UnitOnHitLifesteal


@export var skill_effect_data: EffectDamage
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	print(unit.health)
	unit.heal(skill_level*3)
	print(unit.health)
	var visuals = visual_effect.instantiate()
	unit.add_child(visuals)
	visuals.global_position = unit.global_position
	visuals.play("default")
	await visuals.animation_finished
	visuals.queue_free()
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.ON_HIT)
