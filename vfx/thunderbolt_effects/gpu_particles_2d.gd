extends GPUParticles2D

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()
	#connect("finished", _on_emitting_finished)

#to za wczesnie usuwa, wiec robie łopatologicznie
#func _on_emitting_finished():
	#queue_free()
	#pass
