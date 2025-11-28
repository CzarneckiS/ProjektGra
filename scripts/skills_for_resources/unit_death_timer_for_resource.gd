extends SkillInstant
class_name UnitDeathTimer

@export var death_timer_seconds = 10
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var attack_speed_multiplier = 2
func use(unit: CharacterBody2D) -> void:
	unit.attack_speed_modifier *= attack_speed_multiplier
	await unit.get_tree().create_timer(death_timer_seconds).timeout
	if unit:
		if !unit.dying:
			unit.forced_death()
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.PASSIVE)
