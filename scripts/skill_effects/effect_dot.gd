extends Effect
class_name EffectDamageOverTime

@export var damage_per_tick : int = 5
@export var damage_multiplier : float = 1.0
@export var ticks_per_second : float = 1.0
@export var duration : float = 2.0

func apply(_target: UnitParent) -> void:
	print("test")
	
