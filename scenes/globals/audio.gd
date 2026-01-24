extends Node

func play_audio(audio):
	if !audio.playing:
		audio.pitch_scale = randf_range(0.7, 1.3)
		audio.play()

var main_menu_ost = AudioStreamPlayer.new()
func _ready():
	add_child(main_menu_ost)
	main_menu_ost.stream = load("res://soundtrack/main_menu_normalized.ogg")
	main_menu_ost.bus = "Master"

func play_main_menu():
	if not main_menu_ost.playing:
		main_menu_ost.play()

func stop_main_menu():
	if main_menu_ost.playing:
		main_menu_ost.stop()
