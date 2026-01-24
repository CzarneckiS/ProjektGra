extends Skill
class_name PlayerSummonRespawnTimeUp


@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D):
	player.summon_respawn_timer_modifier = (0.5 + 0.5/(skill_level+1))
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.STAT_UP)
func get_desc() -> String:
	return "if your units die they come back faster\n\n respawn timer: -%s" \
 %[(0.5 + 0.5/(skill_level+1))]
