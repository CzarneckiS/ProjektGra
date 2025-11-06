extends Resource
class_name Skill

@export var skill_name : String = "new_spell"
@export var skill_desc : String = "description"
@export var cooldown : float = 5.0
@export var visual_effect : PackedScene

func use(_player: CharacterBody2D, _target) -> void:
	print("Skill use() invoked.")
