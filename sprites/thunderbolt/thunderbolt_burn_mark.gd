extends Sprite2D

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	var tween = create_tween()
	tween.tween_property(self,"modulate:a",0,3)
	await get_tree().create_timer(3).timeout
	queue_free()
