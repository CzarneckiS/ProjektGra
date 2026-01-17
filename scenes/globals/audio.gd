extends Node

func play_audio(audio):
	if !audio.playing:
		audio.pitch_scale = randf_range(0.7, 1.3)
		audio.play()
