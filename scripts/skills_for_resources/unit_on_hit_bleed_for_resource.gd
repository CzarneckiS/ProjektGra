extends SkillInstant
class_name UnitOnHitBleed

@export var hit_amount: int = 5
@export var skill_effect_data: EffectDamage
@export var damage_interval: float = 0.5
@export var unit_tags : PackedInt32Array = []
@export var use_tags : PackedInt32Array = []
@export var skill_tags : PackedInt32Array = []
func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var bleed_status_effect = BleedStatusEffect.new()
	skill_effect_data.base_damage = 5 + skill_level
	bleed_status_effect.initialize(unit, target, damage_interval, skill_effect_data.base_damage, hit_amount)
func _init() -> void:
	unit_tags.append(Tags.UnitTag.SKELETON_WARRIOR)
	use_tags.append(Tags.UseTag.ON_HIT)
func get_desc() -> String:
	return "[b][color=#dbc4a6]your melee units gain exceptionally sharp blades...[/color][/b]\n\n[table=2][cell]bleed per second: [/cell][cell]%s[/cell]\n[cell]skill level: [/cell][cell]%s[/cell][/table]" \
 %[(3+(skill_level+1))/damage_interval, skill_level]
