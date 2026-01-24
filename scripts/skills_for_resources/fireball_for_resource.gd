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
func update_info():
	damage_to_show += 5
	print("obrazenia fireballa: ", skill_effect_data.base_damage)
	if times_upgraded == 2:
		multiplier_to_show = 1.1
		cooldown_to_show -= 0.2
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)
	if times_upgraded == 4:
		multiplier_to_show = 1.18
		cooldown_to_show -= 0.3
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)
func upgrade_skill():
	times_upgraded += 1
	update_info()
	print("ile razy ulepszono: ", times_upgraded)
	skill_effect_data.base_damage += 5
	print("obrazenia fireballa: ", skill_effect_data.base_damage)
	if times_upgraded == 3:
		skill_effect_data.damage_multiplier = 1.1
		cooldown -= 0.2
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)
	if times_upgraded == 5:
		skill_effect_data.damage_multiplier = 1.18
		cooldown -= 0.3
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)

func get_desc() -> String:
	return "[b][color=#dbc4a6]cast a single projectile in a straight line[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[damage_to_show, multiplier_to_show, cooldown_to_show, skill_level]
