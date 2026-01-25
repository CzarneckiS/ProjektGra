extends Node2D

@onready var button_back_to_menu: Button = $ButtonBackToMenu
@onready var button_back_to_menu_highlight: TextureRect = $ButtonBackToMenu/Highlight

@onready var ach_icons: Array = [
	$AchIcon1, $AchIcon2, $AchIcon3, $AchIcon4, $AchIcon5,
	$AchIcon6, $AchIcon7, $AchIcon8, $AchIcon9, $AchIcon10,
	$AchIcon11, $AchIcon12, $AchIcon13, $AchIcon14, $AchIcon15
]

@onready var text_c: RichTextLabel = $TextC
@onready var text_d: RichTextLabel = $TextD
@onready var text_e: Label = $TextE
@onready var spell_data_icon: TextureRect = $SpellDataIcon

var EMPTY_ICON = preload("res://sprites/icons/question mark.png")

func _ready() -> void:
	button_back_to_menu.pressed.connect(_on_button_backto_menu_pressed)
	button_back_to_menu.focus_mode = Control.FOCUS_NONE
	_setup_hover(button_back_to_menu, button_back_to_menu_highlight)
	for icon: TextureRect in ach_icons:
		icon.scale = Vector2(2.2,2.2)
	
	Achievements.achievement_unlocked.connect(_on_achievement_unlocked)
	
	await get_tree().process_frame
	populate_skill_icons()
	await get_tree().create_timer(1.0).timeout
	
func _on_button_backto_menu_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file","res://scenes/ui/main_menu.tscn")

func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)
	
	
func populate_skill_icons() -> void:
	Achievements.skill_unlock_handler.update_skill_unlock_handler() #odswieża odblokowane skille
	var dict = Achievements.skill_unlock_handler.skill_unlock_dictionary
	var skills = dict.keys()
	var count = min(skills.size(), ach_icons.size())

	for i in range(count):
		var skill = skills[i]
		var is_unlocked = Achievements.achievement_list[dict[skill]]
		var icon_node: TextureRect = ach_icons[i]
		icon_node.visible = false
		icon_node.set_meta("skill_ref", skill)
		icon_node.set_meta("unlocked", is_unlocked)
		
		
		if is_unlocked:
			icon_node.texture = skill.icon
		else:
			icon_node.visible = false

		
		icon_node.custom_minimum_size = Vector2(50, 50)
		icon_node.visible = true
		icon_node.expand = true
		icon_node.stretch_mode = TextureRect.STRETCH_SCALE

		icon_node.update_minimum_size()

		if not icon_node.mouse_entered.is_connected(_on_icon_hover):
			icon_node.mouse_entered.connect(_on_icon_hover.bind(icon_node))

		if not icon_node.mouse_exited.is_connected(_clear_spell_data):
			icon_node.mouse_exited.connect(_clear_spell_data)



func _on_icon_hover(icon_node: TextureRect) -> void:
	var skill = icon_node.get_meta("skill_ref")
	var is_unlocked = icon_node.get_meta("unlocked")
	var achievement_key = icon_node.get_meta("achievement_key", "")
	
	if icon_node.has_meta("achievement_key"):
		achievement_key = icon_node.get_meta("achievement_key", "")
	
	if skill == null:
		return

	if is_unlocked:
		spell_data_icon.texture = skill.icon
		spell_data_icon.visible = true
		if skill.has_method("get_skill_name"):
			text_c.text = skill.get_skill_name()
		else:
			text_c.text = skill.skill_name
		if skill.has_method("get_achievement_desc"):
			text_d.text = skill.get_achievement_desc()
		else:
			text_d.text = skill.get_desc()
		#text_e.text = Achievements.achievement_description_list[Achievements.skill_unlock_handler.skill_unlock_dictionary[skill]]
	else:
		spell_data_icon.texture = EMPTY_ICON
		text_c.text = "???"
		text_d.text = Achievements.achievement_description_list[Achievements.skill_unlock_handler.skill_unlock_dictionary[skill]]
		#text_e.text = 

	spell_data_icon.custom_minimum_size = Vector2(50, 50)
	spell_data_icon.expand = true
	spell_data_icon.stretch_mode = TextureRect.STRETCH_SCALE
	spell_data_icon.update_minimum_size()
	

	


func _clear_spell_data() -> void:
	return
	spell_data_icon.texture = null
	text_c.text = ""
	text_d.text = ""
	text_e.text = ""


func _on_achievement_unlocked(achievement_key: String) -> void:
	print("ACHIEVEMENT UNLOCKED:", achievement_key)

	var skill = Achievements.skill_unlock_handler.skill_unlock_dictionary.find_key(achievement_key)
	if skill == null:
		return

	var description = Achievements.achievement_description_list.get(achievement_key, "")

	print("Skill:", skill.skill_name)
	print("Description:", description)


	populate_skill_icons() 
