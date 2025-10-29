extends Resource
class_name Skill

@export var skill_name : String = "new_spell"
@export var cooldown : float = 5.0
@export var visual_effect : PackedScene
@export var effects : Array[Effect]

func use(_player: CharacterBody2D, _target: UnitParent) -> void:
	print("Skill use() invoked.")
