extends Control

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var title: Label = $Title
@onready var desc: Label = $Description

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_level = true


func show_popup(skill, achievement_desc: String) -> void:
	# === Reset kotwic (bardzo ważne!) ===
	# To sprawia, że position = Vector2(0,0) to lewy górny róg ekranu
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT) 
	
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# === Dane i Ikona (bez zmian) ===
	icon.texture = skill.icon
	title.text = skill.skill_name
	desc.text = achievement_desc
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(50, 50)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# === Rozmiar ===
	custom_minimum_size = Vector2(250, 80)
	# Zamiast ustawiać rozmiar tła ręcznie, ustaw tło na "Full Rect" w edytorze
	visible = true

	# Czekamy na przeliczenie rozmiarów
	await get_tree().process_frame

	# === Logika pozycjonowania (PRAWY GÓRNY RÓG) ===
	var margin := 20
	var viewport_size := get_viewport_rect().size
	
	# Cel: szerokość ekranu - szerokość popupa - margines
	var target_x := viewport_size.x - size.x - margin
	var y_pos := margin

	# Start: całkiem poza prawą krawędzią
	position = Vector2(viewport_size.x + 10, y_pos)

	# === Animacja (bez zmian) ===
	var tween := create_tween()
	
	# Wjazd do target_x
	tween.tween_property(self, "position:x", target_x, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_interval(3.0)

	# Wyjazd z powrotem poza ekran
	tween.tween_property(self, "position:x", viewport_size.x + 10, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.finished.connect(queue_free)
