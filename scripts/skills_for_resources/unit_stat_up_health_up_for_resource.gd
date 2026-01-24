extends Skill
class_name UnitStatUpHealthUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var damage_bonus : int = 15
func use(unit: CharacterBody2D):
	unit.max_health = unit.base_max_health + skill_level * 20
	unit.health_bar.max_value = unit.max_health
	unit.damage_bar.max_value = unit.max_health
	unit.heal(skill_level * 20)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "bones of your units are sturdier\n\n unit health: +%s" \
 %[skill_level * 20]
