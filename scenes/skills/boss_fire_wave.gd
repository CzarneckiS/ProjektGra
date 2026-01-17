extends Area2D


var start_position: Vector2
var direction: Vector2
var hit: bool = false
var damage: int
var starting_distance: float = 100
var speed: float = 100
var max_range: float = 800
var acceleration: float = 400
var units_hit_array : Array[CharacterBody2D] = []

func initialize(start_pos: Vector2, target_pos: Vector2, _damage: int):
	damage = _damage
	start_position = start_pos
	direction = (target_pos - start_pos).normalized()
	global_position = start_pos + direction * starting_distance
	look_at(global_position+direction)

func _physics_process(delta: float) -> void:
	speed += acceleration*delta
	global_position += direction * speed * delta
	if global_position.distance_to(start_position) > max_range:
		call_deferred("queue_free")
func _ready():
	Audio.play_audio($sfx_firewave)
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AnimatedSprite2D.play("on_creation")

func _on_body_entered(body: CharacterBody2D):
	if body not in units_hit_array:
		if body:
			units_hit_array.append(body)
			body.hit(damage,self)

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "on_creation":
		$AnimatedSprite2D.play("default")
