extends Skill

@export var damage : int = 30
func use(unit: CharacterBody2D, target: CharacterBody2D):
	var homing_projectile = visual_effect.instantiate()
	unit.get_parent().add_child(homing_projectile)
	homing_projectile.initialize(unit.global_position, target, damage)
