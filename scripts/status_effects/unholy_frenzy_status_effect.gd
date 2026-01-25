extends RefCounted
class_name UnholyFrenzyStatusEffect

var damage = 3.5

func initialize(unit):
	unit.status_effects_array.append(self)
	while unit:
		await unit.get_parent().get_tree().create_timer(0.5, false).timeout
		if unit:
			if !unit.dying:
				unit.hit(damage, self)
