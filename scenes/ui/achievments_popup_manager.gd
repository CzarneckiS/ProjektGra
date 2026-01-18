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
	print("$PopupManager parent:", get_parent())
	print("$PopupManager parent:", get_parent())
'''	
extends Node
class_name PopupManager

var popup_root: Control = null
var popup_scene = preload("res://scenes/ui/achievements_popup.tscn")

func _ready() -> void:
	
	Achievements.achievement_unlocked.connect(show_achievement_popup)

func register_popup_root(root: Control) -> void:
	if popup_root != null:
		print("$Popup root already registered, ignoring:", popup_root)
		return
	popup_root = root
	print("$Popup root registered:", popup_root)

func show_achievement_popup(achievement_key: String) -> void:
	var skill = Achievements.skill_unlock_handler.skill_unlock_dictionary.find_key(achievement_key)
	if skill == null:
		return
	var desc = Achievements.achievement_description_list.get(achievement_key, "")
	
	var popup = popup_scene.instantiate()
	popup_root.add_child(popup)
	popup.show_popup(skill, desc)'''
