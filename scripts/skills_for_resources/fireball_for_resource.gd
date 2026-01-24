extends SkillRangeBased
class_name Fireball

@export var skill_effect_data: EffectDamage
@export var effect_knockback: EffectKnockback
@export var amount: int
@export var offset: Vector2
var damage_to_show
var multiplier_to_show
var cooldown_to_show
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(player, target_position: Vector2, shift: float = 0.0) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(player, target_position, self, shift)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func upgrade_skill():
	skill_effect_data.base_damage = 15+(3*skill_level)
	cooldown = 4 - (0.1 * skill_level)

func get_desc() -> String:
		if skill_level > 0:
			return "[b][color=#dbc4a6]cast a single projectile in a straight line[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage+3, skill_effect_data.damage_multiplier, cooldown-0.1, skill_level]
		return "[b][color=#dbc4a6]cast a single projectile in a straight line[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage, skill_effect_data.damage_multiplier, cooldown, skill_level]
