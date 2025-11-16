extends Skill
class_name UnitStatUpAttackUp


@export var tags : Dictionary = {}
@export var damage_bonus : int = 15
func use(unit: CharacterBody2D):
	unit.damage = unit.base_damage + (damage_bonus * skill_level)
func _init() -> void:
	tags["AlliedUnit"] = tags.size()
	tags["StatUp"] = tags.size()
