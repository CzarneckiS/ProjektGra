extends Node

func play_audio(audio):
	if !audio.playing:
		audio.pitch_scale = randf_range(0.8, 1.2)
		audio.play()
