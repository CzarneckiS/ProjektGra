extends Control

func _ready() -> void:
	$TextureProgressBar3.visible = false
	$TextureProgressBar4.visible = false
	$TextureProgressBar.value = 0
	$TextureProgressBar2.value = 0
	var tween1 = create_tween()
	tween1.set_parallel(true)
	tween1.set_ease(Tween.EASE_OUT)
	tween1.tween_property($TextureProgressBar, "value", 100, 0.4)
	tween1.tween_property($TextureProgressBar2, "value", 100, 0.4)
	tween1.tween_property($GPUParticles2D, "position:x",$TextureProgressBar3.global_position.x-630 , 0.4)
	tween1.tween_property($GPUParticles2D2, "position:x", $TextureProgressBar4.global_position.x+630, 0.4)
	await tween1.finished
	$GPUParticles2D.one_shot = true
	$GPUParticles2D2.one_shot = true
	await get_tree().create_timer(0.3).timeout
	$GPUParticles2D3.emitting = true
	$TextureProgressBar3.visible = true
	$TextureProgressBar4.visible = true
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property($BlackRect, "value",100 , 0.3)
	tween2.tween_property($TextureProgressBar3, "position:y",$TextureProgressBar3.global_position.y+210 , 0.3)
	tween2.tween_property($TextureProgressBar4, "position:y", $TextureProgressBar4.global_position.y+210, 0.3)
	tween2.tween_property($GPUParticles2D3, "position:y", $TextureProgressBar4.global_position.y+140, 0.3)
	await tween2.finished
	$GPUParticles2D3.one_shot = true
	var tween3 = create_tween()
	tween3.tween_property($Label, "modulate:a",1 , 0.2)
