extends SkillInstant
class_name Iceblock

@export var effect_damage: EffectDamage
@export var effect_knockback: EffectKnockback
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
	effect_damage.base_damage = 20 + (5*skill_level)
	effect_damage.damage_multiplier = 1.0 + (0.06 * skill_level)
	cooldown = 7 - (0.2*skill_level)
func get_desc() -> String:
	if skill_level > 0:
		return "[b][color=#dbc4a6]block the enemy path[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(effect_damage.base_damage+5)*(effect_damage.damage_multiplier+0.06), cooldown-0.2, skill_level]
	return "[b][color=#dbc4a6]block the enemy path[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(effect_damage.base_damage * effect_damage.damage_multiplier), cooldown, skill_level]

func get_achievement_desc() -> String:
	return "[b][color=#dbc4a6]block the enemy path[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell][/table]" \
 %[(effect_damage.base_damage * effect_damage.damage_multiplier), cooldown]

func tooltip_desc():
	return "[b][color=#dbc4a6]block the enemy path[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(effect_damage.base_damage * effect_damage.damage_multiplier), cooldown, skill_level]
