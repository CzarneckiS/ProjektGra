extends Control

@export var popup_scene: PackedScene = preload("res://scenes/ui/achievements_popup.tscn")

func _ready() -> void:
	Achievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_key: String) -> void:
	var skill = Achievements.skill_unlock_handler.skill_unlock_dictionary.find_key(achievement_key)

	if skill == null:
		return

	var desc = Achievements.achievement_description_list.get(achievement_key, "")
	var popup = popup_scene.instantiate()
	add_child(popup)
	popup.show_popup(skill, desc)
