extends Node2D

func _ready() -> void:
	$heal_animation.animation_finished.connect(_on_animation_finished)
	$heal_animation.play("default")
	
func _on_animation_finished():
	call_deferred("queue_free")
