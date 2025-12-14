extends SkillInstantAllied
class_name Heal

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var skill_effect_data: EffectHeal
@export var skill_effect_data2: EffectAreaOfEffect

func use(player: CharacterBody2D, _target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_tree().root.add_child(projectile_node)
	projectile_node.initialize(player, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
