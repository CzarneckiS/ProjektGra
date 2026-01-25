extends Node2D

@onready var button_back_to_menu: Button = $ButtonBackToMenu
@onready var button_back_to_menu_highlight: TextureRect = $ButtonBackToMenu/Highlight
@onready var button_save: Button = $SAVE
@onready var button_save_highlight: TextureRect = $SAVE/Highlight

# Nowe elementy UI
@onready var volume_slider: HSlider = $VolumeSlider
@onready var volume_label: Label = $VolumeValueLabel

func _ready() -> void:
	# Obsługa przycisków
	button_back_to_menu.pressed.connect(_on_button_backto_menu_pressed)
	button_back_to_menu.focus_mode = Control.FOCUS_NONE
	_setup_hover(button_back_to_menu, button_back_to_menu_highlight)
	
	button_save.focus_mode = Control.FOCUS_NONE
	_setup_hover(button_save, button_save_highlight)
	
	# Konfiguracja suwaka głośności
	if volume_slider:
		# Łączymy sygnał zmiany wartości
		var current_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
		volume_slider.value = db_to_linear(current_db) * 100
		volume_slider.value_changed.connect(_on_volume_value_changed)
		# Ustawiamy początkowy tekst labela na podstawie startowej wartości suwaka
		_update_volume_label(volume_slider.value)

func _on_button_backto_menu_pressed() -> void:
	$click_sfx.play()
	await $click_sfx.finished
	get_tree().call_deferred("change_scene_to_file","res://scenes/ui/main_menu.tscn")

func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)

# Funkcja wywoływana przy przesuwaniu suwaka
func _on_volume_value_changed(value: float) -> void:
	_update_volume_label(value)
	var volume_db = linear_to_db(value/100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value<=0)

# Pomocnicza funkcja do aktualizacji napisu %
func _update_volume_label(value: float) -> void:
	if volume_label:
		# Jeśli Twój suwak ma zakres 0-1, używamy value * 100
		# Jeśli masz zakres 0-100, usuń "* 100"
		var percentage = int(value)
		volume_label.text = str(percentage) + "%"
