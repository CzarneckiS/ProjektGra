extends Effect
class_name EffectDamage

@export var base_damage : int = 15
@export var damage_multiplier : float = 1.0

func apply(_target: UnitParent) -> void:
	print("EffectDamage apply() invoked.")
