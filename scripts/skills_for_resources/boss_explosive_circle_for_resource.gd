extends Skill
class_name BossExplosiveCircle

@export var damage : int = 30
func use(unit: CharacterBody2D, target_position: Vector2):
	var explosive_circle = visual_effect.instantiate()
	unit.get_parent().add_child(explosive_circle)
	explosive_circle.initialize(target_position, damage)
