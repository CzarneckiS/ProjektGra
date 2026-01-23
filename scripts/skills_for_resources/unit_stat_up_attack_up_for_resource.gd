extends Skill
class_name UnitStatUpAttackUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var damage_bonus : int = 15
func use(unit: CharacterBody2D):
	unit.damage = unit.base_damage + (damage_bonus * skill_level)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.ALLIED)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "your units hit harder\n\n unit damage: +%s" \
 %[damage_bonus * skill_level]
