extends Area2D
class_name HealSpell

var skill_resource: Heal
var player_pos #player_pos? to nie jest pozycja, chyba powinno byc zmienione?
const heal_vfx = preload("res://scenes/skills/heal_vfx.tscn")

func initialize(player, skill_res: Heal):
	skill_resource = skill_res
	player_pos = player
	global_position = player.global_position
	if player is CharacterBody2D:
		$heal_animation.play("player")
		heal_player()
	else:
		$heal_animation.play("default")
	if skill_resource.skill_effect_data2 != null:
		if $heal_collision.shape:
			var base_radius = skill_resource.skill_effect_data2.radius
			var shape_duplicate = $heal_collision.shape.duplicate()
			$heal_collision.shape = shape_duplicate
			
			shape_duplicate.radius = base_radius * skill_resource.skill_effect_data2.radius_multiplier
	
func _process(_delta):
	if player_pos != null:
		global_position = player_pos.global_position
	
func _ready():
	$heal_animation.animation_finished.connect(_on_animation_finished)
	$heal_sfx.play()
	$heal_sfx.finished.connect(_on_sfx_finished)
	body_entered.connect(_on_body_entered)
	
func _on_animation_finished():
	call_deferred("hide")

func _on_body_entered(body: UnitParent):
	if body.is_in_group("Allied"):
		body.heal(skill_resource.skill_effect_data.base_heal * skill_resource.skill_effect_data.heal_multiplier)
		display_heal_vfx(body)

func display_heal_vfx(target: Node2D):
	if heal_vfx:
		var vfx_instance = heal_vfx.instantiate()
		target.add_child(vfx_instance)
		vfx_instance.position = Vector2.ZERO

func heal_player():
	player_pos.heal(skill_resource.skill_effect_data.base_heal * skill_resource.skill_effect_data.heal_multiplier)

func _on_sfx_finished():
	call_deferred("queue_free")
