extends Control
class_name SkillTooltip

@onready var label: Label = $Text

# Wewnątrz klasy SkillTooltip
var descriptions = {
	"Attack": "[Z] Rozkazuje jednostkom atakować cele w zasięgu.",
	"Hold": "[X] Jednostki stoją w miejscu i bronią pozycji.",
	"Move": "[RMB] Przemieszcza jednostki do wskazanego punktu.",
	"Stop": "[C] Przerywa wszystkie aktualne akcje.",
}

func show_text(icon_name):
	label.text = icon_name + "\n" + descriptions.get(icon_name, "")
	visible = true
	
func show_spell_text(_skill: Skill):
	label.text = _skill.skill_name + "\n" + _skill.skill_desc
	visible = true
		
func hide_tooltip():
	visible = false
