extends Skill
class_name SkillInstant

#func use(player: CharacterBody2D, target_position: Vector2) -> void:
	#var projectile_node = visual_effect.instantiate()
	#player.get_tree().root.add_child(projectile_node)
	#projectile_node.initialize(target_position, self)
