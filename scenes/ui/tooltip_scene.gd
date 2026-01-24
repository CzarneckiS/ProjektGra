extends Control
class_name SkillTooltip

@onready var label: Label = $Text

# Wewnątrz klasy SkillTooltip
var descriptions = {
	"Attack": "[A] Rozkazuje jednostkom atakować cele w zasięgu.",
	"Hold": "[H] Jednostki stoją w miejscu i bronią pozycji.",
	"Move": "[M] Przemieszcza jednostki do wskazanego punktu.",
	"Stop": "[?] Przerywa wszystkie aktualne akcje.",
}

func show_text(icon_name):
	label.text = icon_name + "\n" + descriptions.get(icon_name, "")
	visible = true
	
func show_spell_text(_skill: Skill):
	label.text = _skill.skill_name + "\n" + _skill.skill_desc
	visible = true
		
func hide_tooltip():
	visible = false
