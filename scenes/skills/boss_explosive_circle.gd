extends Area2D
class_name BossExplosiveCircleSpell

var damage

func initialize(spawn_position: Vector2, skill_damage: int):
	damage = skill_damage
	global_position = spawn_position

func _ready():
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)

func _on_animation_finished():
	call_deferred("queue_free")
	
func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body: CharacterBody2D):
	print("got you mafk")
	#if !body.is_in_group("Allied"):
		#body.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
		#skill_resource.skill_effect_data3.apply_push(global_position, body)
