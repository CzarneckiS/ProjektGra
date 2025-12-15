extends SkillRangeBased
class_name HumanArcherProjectile

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var projectile_node = visual_effect.instantiate()
	unit.get_parent().add_child(projectile_node)
	projectile_node.initialize(unit, target, self)
