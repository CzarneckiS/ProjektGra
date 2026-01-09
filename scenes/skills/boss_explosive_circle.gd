extends Area2D
class_name BossExplosiveCircleSpell

var damage
var units_hit_array : Array[CharacterBody2D] = []

func initialize(spawn_position: Vector2, skill_damage: int):
	damage = skill_damage
	global_position = spawn_position

func _ready():
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	monitorable = false
	monitoring = false

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "default":
		$AnimatedSprite2D.play("exploding")
		monitorable = true
		monitoring = true
	elif $AnimatedSprite2D.animation == "exploding":
		call_deferred("queue_free")
	
func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body: CharacterBody2D):
	if body not in units_hit_array:
		if body:
			units_hit_array.append(body)
			body.hit(damage,self)
