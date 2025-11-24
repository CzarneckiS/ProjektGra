extends Node2D

func _ready() -> void:
	var timer = get_tree().create_timer(0.15)
	await timer.timeout
	queue_free()

func initialize(unit: CharacterBody2D, target: CharacterBody2D):
	global_position = unit.global_position
	look_at(target.global_position)
