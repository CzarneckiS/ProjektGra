extends SkillInstant
class_name UnitDeathTimer

@export var death_timer_seconds = 10
@export var tags : Dictionary = {}
@export var attack_speed_multiplier = 2
func use(unit: CharacterBody2D) -> void:
	unit.attack_speed_modifier *= attack_speed_multiplier
	await unit.get_tree().create_timer(death_timer_seconds).timeout
	if unit:
		if !unit.dying:
			unit.forced_death()
func _init() -> void:
	tags["AlliedUnit"] = tags.size()
	tags["Passive"] = tags.size()
