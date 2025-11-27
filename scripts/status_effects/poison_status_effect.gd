extends RefCounted
class_name PoisonStatusEffect

var debuff_owner
var hits_left = 5

enum Smegmaballs{
	LOL,
	LMAO
}

func initialize(unit, target, damage_interval, damage, hit_amount):
	debuff_owner = unit
	hits_left = hit_amount
	target.status_effects_array.append(self)
	while hits_left > 0 and target:
		await target.get_parent().get_tree().create_timer(damage_interval).timeout
		if target:
			if !target.dying:
				target.hit(damage, self)
		hits_left -= 1
	if target:
		target.status_effects_array.erase(self)
		
