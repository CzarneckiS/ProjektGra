extends Node2D
class_name OrbSpell

var skill_resource: Orb
var lifetime: Timer = Timer.new()
var used_timer: Timer = Timer.new()
var used: bool = false

var orb_position: Vector2
var hit: bool = false

@onready var orb_collision_damage: CollisionShape2D = $orb_collision_damage_area/orb_collision_damage
@onready var orb_collision_heal: CollisionShape2D = $orb_collision_heal_area/orb_collision_heal
@onready var orb_collision_damage_area: Area2D = $orb_collision_damage_area
@onready var orb_collision_heal_area: Area2D = $orb_collision_heal_area

var heal_skill: Resource = preload("res://resources/heal.tres")

func initialize(user, _target_position, skill_res: Orb):
	skill_resource = skill_res
	
	orb_position = user.global_position
	global_position = orb_position
	
	add_child(lifetime)
	lifetime.wait_time = skill_resource.orb_lifetime
	lifetime.autostart = true
	lifetime.one_shot = true
	lifetime.timeout.connect(_on_lifetime_timeout)
	
	add_child(used_timer)
	used_timer.wait_time = 0.5
	used_timer.autostart = true
	used_timer.one_shot = true
	used_timer.timeout.connect(_on_used_timer_timeout)
	
func _ready():
	lifetime.call_deferred("start")
	$orb_animation.play("default")
	$orb_collision_area.body_entered.connect(_on_body_entered)
	orb_collision_damage_area.body_entered.connect(_on_orb_collision_damage_area_entered)
	orb_collision_heal_area.body_entered.connect(_on_orb_collision_heal_area_entered)
	
func _physics_process(_delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
	
func _on_body_entered(player):
	if player.is_in_group("Player") and !used:
		apply_effect(player)
		used = true
		used_timer.start()

func _on_lifetime_timeout():
	call_deferred("queue_free")

func apply_effect(_player):
	var choices = ["explosion", "heal", "exp"]
	var choice = choices.pick_random()
	play_animation(choice)
	match choice:
		"explosion":
			orb_collision_damage.set_deferred("disabled", false)
		"heal":
			orb_collision_heal.set_deferred("disabled", false)
		"exp":
			Globals.update_player_exp(skill_resource.give_exp_amount)
	
func _on_orb_collision_damage_area_entered(body):
	if !body.is_in_group("Allied") and body.has_method("hit"):
		body.hit(skill_resource.effect_damage.base_damage * skill_resource.effect_damage.damage_multiplier, self)

var heal_triggered: bool = false

func _on_orb_collision_heal_area_entered(_body):
	if !heal_triggered:
		heal_triggered = true
		heal_skill.call_deferred("use", self, global_position)
	
func _on_used_timer_timeout():
	call_deferred("queue_free")

func play_animation(orb_type: String):
	var transform_color: Color = Color.WHITE
	var transform_tween = create_tween()
	
	match orb_type:
		"explosion":
			transform_color = Color("d3005b") * 3.0
		"heal":
			transform_color = Color("f829ff") * 3.0
		"exp":
			transform_color = Color("767cff") * 3.0
		_:
			pass
	transform_tween.tween_property($orb_animation, "self_modulate", transform_color, 0.35)
	transform_tween.set_ease(Tween.EASE_OUT)
