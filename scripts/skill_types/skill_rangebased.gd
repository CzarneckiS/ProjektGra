extends Skill
class_name SkillRangeBased

@export var max_range : float = 250.0
@export var speed: float = 100.0

func shoot(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(player.global_position, target_position, self)
