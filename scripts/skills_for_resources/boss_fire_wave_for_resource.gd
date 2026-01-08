extends Skill

@export var damage : int = 30
func use(unit: CharacterBody2D, target_position: Vector2):
	var fire_wave = visual_effect.instantiate()
	unit.get_parent().add_child(fire_wave)
	fire_wave.initialize(unit.global_position, target_position, damage)
