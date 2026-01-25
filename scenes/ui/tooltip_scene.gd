extends Control
class_name SkillTooltip

@onready var label: Label = $Text

# Wewnątrz klasy SkillTooltip
var descriptions = {
	"Attack": "[Z] Rozkazuje jednostkom atakować cele w zasięgu.",
	"Hold": "[C] Jednostki stoją w miejscu i bronią pozycji.",
	"Move": "[RMB Przemieszcza jednostki do wskazanego punktu.",
	"Stop": "[X] Przerywa wszystkie aktualne akcje.",
	1: "[Q] ",
	2: "[E] ",
	3: "[R] ",
	4: "[F] "
}

func show_text(icon_name):
	label.text 	= icon_name + "\n" + descriptions.get(icon_name, "")
	visible = true
	
func show_spell_text(_skill: Skill, _order_number = null):
	label.text = descriptions.get(_order_number, "") + _skill.skill_name + "\n" + _skill.skill_desc
	visible = true
		
func hide_tooltip():
	visible = false
