extends Resource
class_name Skill

@export var skill_name : String = "new_spell"
@export var skill_desc : String = "description"
@export var skill_level : int = 0
@export var cooldown : float = 5.0
@export var visual_effect : PackedScene
@export var effects : Array[Effect] #czy to jest w ogole uzywane?
@export var icon : CompressedTexture2D
func _use() -> void:
	print("Skill use() invoked.")
