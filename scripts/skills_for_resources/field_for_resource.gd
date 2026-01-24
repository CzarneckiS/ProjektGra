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
func upgrade_skill():
	dot_effect.damage_per_tick = 7 + (2*skill_level)
	dot_effect.ticks_per_second = 2.0 + (0.2*skill_level)
	dot_effect.duration = 3.0 + (0.3*skill_level)
	aoe_effect.radius = 200.0 + (15*skill_level)
	cooldown = 8 - (0.4*skill_level)
func get_desc() -> String:
	if skill_level > 0:
		return "[b][color=#dbc4a6]pull enemies inside and watch them die[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(dot_effect.damage_per_tick+2)*(dot_effect.ticks_per_second+0.2), aoe_effect.radius, dot_effect.duration+0.3, cooldown-0.4, skill_level]
	return "[b][color=#dbc4a6]pull enemies inside and watch them die[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[dot_effect.damage_per_tick*dot_effect.ticks_per_second, aoe_effect.radius, dot_effect.duration, cooldown, skill_level]

func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]pull enemies inside and watch them die[/color][/b]\n\n[table=2][cell]damage per second: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]duration: [/cell][cell]%s[/cell]\n\n[cell]cooldown: [/cell][cell]%s[/cell][/table]" \
 %[dot_effect.damage_per_tick*dot_effect.ticks_per_second, aoe_effect.radius, dot_effect.duration, cooldown]

func get_skill_name() -> String:
	return "[shake rate=20.0 level=6 connected=0][rainbow freq=2.0 sat=0.4 val=1.0 speed=0.5]Oblivion[/rainbow][/shake]"
