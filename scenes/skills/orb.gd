extends Node2D
class_name OrbSpell

var skill_resource: Orb
var lifetime: Timer = Timer.new()

var orb_position: Vector2
var hit: bool = false

func initialize(user, _target_position, skill_res: Orb):
	skill_resource = skill_res
	
	orb_position = user.global_position
	global_position = orb_position
	
	add_child(lifetime)
	lifetime.wait_time = 3.0
	lifetime.autostart = true
	lifetime.one_shot = false
	
func _ready():
	$orb_animation.play("default")
	$orb_collision_area.body_entered.connect(_on_body_entered)
	lifetime.timeout.connect(_on_lifetime_timeout)
	
func _physics_process(_delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
	
func _on_body_entered(player):
	if player.is_in_group("Player"):
		apply_effect(player)

func _on_lifetime_timeout():
	call_deferred("queue_free")

func apply_effect(_player):
	var choice: int = 1
	match choice:
		1:
			print("siemano kolano")
			Globals.update_player_exp(skill_resource.give_exp_amount)
