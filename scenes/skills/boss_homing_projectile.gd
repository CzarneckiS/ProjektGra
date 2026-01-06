extends Area2D

var start_position: Vector2
var direction: Vector2
var course_correction = 0
var max_steer_force = 40
var current_velocity : Vector2
var desired_velocity : Vector2
var speed = 600
var target
var hit: bool = false
var damage
#im dluzej pocisk leci tym slabszy ma steering!
func initialize(start_pos: Vector2, target_unit: CharacterBody2D, _damage):
	damage = _damage
	start_position = start_pos
	global_position = start_pos
	target = target_unit
	var starting_velocity = (target.global_position - start_pos).normalized() * speed
	current_velocity = Vector2((starting_velocity.x*cos(randf_range(-3,3))-starting_velocity.y*sin(randf_range(-3,3))),(starting_velocity.x*sin(randf_range(-3,3))+starting_velocity.y*cos(randf_range(-3,3))))
	#look_at(target_pos)
func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AnimatedSprite2D.play("on_creation")
	$Timer.connect("timeout", _on_timer_timeout)
	
func _physics_process(delta: float) -> void:
	#var current_distance: float = start_position.distance_to(global_position)
	max_steer_force -= delta*30
	desired_velocity = (target.global_position - global_position).normalized() * speed
	current_velocity += (desired_velocity-current_velocity).limit_length(max_steer_force)
	look_at(global_position+current_velocity)
	global_position += current_velocity * delta

func _on_body_entered(body: CharacterBody2D):
	if body:
		body.hit(damage,self)
	call_deferred("queue_free")

func _on_timer_timeout():
	call_deferred("queue_free")

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "on_creation":
		$AnimatedSprite2D.play("default")
