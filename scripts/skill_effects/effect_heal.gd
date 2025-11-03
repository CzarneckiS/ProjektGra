extends Effect
class_name EffectHeal

@export var base_heal: float = 10.0
@export var heal_multiplier: float = 1.0

func apply(_target: UnitParent) -> void:
	print("EffectHeal apply() invoked.")
