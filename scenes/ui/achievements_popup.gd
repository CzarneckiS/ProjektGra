extends Control

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var title: Label = $Title
@onready var desc: Label = $Description

func show_popup(skill, achievement_desc: String) -> void:
	icon.texture = skill.icon
	title.text = skill.skill_name
	desc.text = achievement_desc
	
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(50, 50)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	visible = true
	custom_minimum_size = Vector2(250, 80)
	background.custom_minimum_size = custom_minimum_size
	
	await get_tree().process_frame 
	position = Vector2(get_viewport_rect().size.x + size.x, 20)

	var tween = create_tween()
	tween.tween_property(
		self,
		"position:x",
		get_viewport_rect().size.x - size.x - 20,
		0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3.0)
	tween.tween_property(
		self,
		"position:x",
		get_viewport_rect().size.x + size.x,
		0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
