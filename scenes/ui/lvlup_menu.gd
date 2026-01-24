extends Control

@onready var name_1: Label = $Option1/Name
@onready var name_2: Label = $Option2/Name
@onready var name_3: Label = $Option3/Name

@onready var description_1: Label = $Option1/Description
@onready var description_2: Label = $Option2/Description
@onready var description_3: Label = $Option3/Description

@onready var texture_rect_1: TextureRect = $Option1/Icon
@onready var texture_rect_2: TextureRect = $Option2/Icon
@onready var texture_rect_3: TextureRect = $Option3/Icon

@onready var option_1: Button = $Option1
@onready var option_2: Button = $Option2
@onready var option_3: Button = $Option3

@onready var highlight_1: TextureRect = $Option1/Highlight
@onready var highlight_2: TextureRect = $Option2/Highlight
@onready var highlight_3: TextureRect = $Option3/Highlight

var skills_to_show: Array

func _ready() -> void:
	$sfx_lvlup.play()
	$sfx_lvlup.finished.connect(_on_sfx_finished)
	option_1.focus_mode = Control.FOCUS_NONE
	option_2.focus_mode = Control.FOCUS_NONE
	option_3.focus_mode = Control.FOCUS_NONE

	_setup_hover(option_1, highlight_1)
	_setup_hover(option_2, highlight_2)
	_setup_hover(option_3, highlight_3)

	level_up()

var pressed: bool = false
func _process(_delta):
	if pressed and sfx_finished:
		queue_free()

func _setup_hover(btn: Button, highlight: TextureRect) -> void:
	highlight.visible = false
	btn.mouse_entered.connect(func(): highlight.visible = true)
	btn.mouse_exited.connect(func(): highlight.visible = false)


func level_up():
	skills_to_show = Skills.get_skill()


	#ta pętla przechodzi przez wszystkie komponenty @onready i zmienia teksty i td
	#tak naprawde zmienia się tylko cyferka przy nazwie 
	#żeby nie pisać  6*3 = 18 linijek jednakowego kodu
	for i in range(skills_to_show.size()):
		self.get("name_" + str(i + 1)).text = skills_to_show[i].skill_name
		self.get("texture_rect_" + str(i + 1)).texture = skills_to_show[i].icon
		if skills_to_show[i].has_method("get_desc"):
			self.get("description_" + str(i + 1)).text = skills_to_show[i].get_desc()
		
		# !!! TRZEBA PRZETESTOWAĆ !!!
		#przetestowalem, nie dziala
		if Skills.unlocked_skills.has(skills_to_show[i].skill_name):
			self.get("option_" + str(i + 1)).text = "Upgrade skill"
		else:
			self.get("option_" + str(i + 1)).text = "Unlock skill"


func _on_option_1_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	Skills.unlock_skill(skills_to_show[0])
	Achievements.achievement_update(Achievements.Event.SKILL_UPDATED, skills_to_show[0])
	hide()
	pressed = true

func _on_option_2_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	Skills.unlock_skill(skills_to_show[1])
	Achievements.achievement_update(Achievements.Event.SKILL_UPDATED, skills_to_show[1])
	hide()
	pressed = true
	
func _on_option_3_pressed() -> void:
	$menu_click.play()
	await $menu_click.finished
	get_tree().paused = false
	Skills.unlock_skill(skills_to_show[2])
	Achievements.achievement_update(Achievements.Event.SKILL_UPDATED, skills_to_show[2])
	hide()
	pressed = true
	
var sfx_finished: bool = false

func _on_sfx_finished():
	sfx_finished = true
