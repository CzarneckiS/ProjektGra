extends SkillInstant
class_name Thunderbolt

@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
@export var skill_effect_data: EffectDamage
@export var skill_effect_data2: EffectAreaOfEffect
@export var skill_effect_data3: EffectKnockback

func use(player, target_position: Vector2) -> void:
	var projectile_node = visual_effect.instantiate()
	player.get_parent().add_child(projectile_node)
	projectile_node.initialize(target_position, self)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.PLAYER)
	use_tags.append(Tags.UseTag.ACTIVE)
func upgrade_skill():
	times_upgraded += 1
	print("ile razy ulepszono: ", times_upgraded)
	skill_effect_data.base_damage += 7
	skill_effect_data2.radius += 15.0
	print("obrazenia fireballa: ", skill_effect_data.base_damage)
	if times_upgraded == 3:
		skill_effect_data.damage_multiplier = 1.03
		skill_effect_data2.radius_multiplier = 1.05
		cooldown -= 0.1
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)
	if times_upgraded == 5:
		skill_effect_data.damage_multiplier = 1.1
		skill_effect_data2.radius_multiplier = 1.6
		cooldown -= 0.3
		print("mnoznik fireballa: ", skill_effect_data.damage_multiplier)
		print("cooldown fireballa: ", cooldown)
func get_desc() -> String:
	return "[b][color=#dbc4a6]strike the designated point[/color][/b]\n\n[table=2][cell]damage: [/cell][cell]%s[/cell]\n[cell]damage multiplier: [/cell][cell]%s[/cell]\n[cell]radius: [/cell][cell]%s[/cell]\n[cell]radius multiplier: [/cell][cell]%s[/cell]\n[cell]cooldown: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[skill_effect_data.base_damage, skill_effect_data.damage_multiplier, skill_effect_data2.radius, skill_effect_data2.radius_multiplier, cooldown, skill_level]
