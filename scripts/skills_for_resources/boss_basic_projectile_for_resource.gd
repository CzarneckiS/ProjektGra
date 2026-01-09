extends SkillRangeBased

func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var projectile_node = visual_effect.instantiate()
	unit.get_parent().add_child(projectile_node)
	projectile_node.initialize(unit.global_position, target.global_position)
