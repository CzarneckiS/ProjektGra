extends SkillInstant
class_name Field

@export var push_effect: EffectPull
@export var aoe_effect: EffectAreaOfEffect
@export var dot_effect: EffectDamageOverTime
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player: CharacterBody2D, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func get_desc() -> String:
	return "[b][color=#dbc4a6]pull enemies inside and watch them die[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[dot_effect.damage_per_tick*dot_effect.ticks_per_second, dot_effect.damage_multiplier, dot_effect.duration, cooldown, skill_level]
