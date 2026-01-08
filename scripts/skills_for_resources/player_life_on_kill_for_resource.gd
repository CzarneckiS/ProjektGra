extends SkillInstant
class_name PlayerLifeOnKill

@export var skill_effect_data: EffectDamage
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D) -> void:
	player.heal(skill_level * 2)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.UNIT_DEATH)
