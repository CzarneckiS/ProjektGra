extends SkillRangeBased
class_name SkeletonMageProjectile

@export var tags : Dictionary = {}
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var projectile_node = visual_effect.instantiate()
	unit.get_parent().get_tree().root.add_child(projectile_node)
	projectile_node.initialize(unit, target, self)
