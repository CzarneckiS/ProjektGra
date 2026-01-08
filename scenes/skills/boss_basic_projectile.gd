extends Area2D

var start_position: Vector2
var direction: Vector2
var max_range = 800
var speed = 500
var damage = 20

func initialize(start_pos: Vector2, target_pos: Vector2):
	start_position = start_pos
	global_position = start_pos
	direction = (target_pos - start_pos).normalized()
	look_at(target_pos)
	
func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AnimatedSprite2D.play("on_creation")

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	var current_distance: float = start_position.distance_to(global_position)
	if current_distance >= max_range:
		queue_free()
	
func _on_body_entered(body: CharacterBody2D):
	if body:
		body.hit(damage, self)
	call_deferred("queue_free")

func _on_animation_finished():
	$AnimatedSprite2D.play("default")
