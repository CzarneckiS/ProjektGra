extends Control
class_name SkillTooltip

@onready var label: Label = $Text

var descriptions = {
	"Blight": "[1] opis do Blight",
	"Glacial barrier": "[4] blablabla",
	"3": "opis3"
}

func show_text(skill_name):
	label.text = skill_name + "\n" + descriptions.get(skill_name, "Brak opisu")
	visible = true
	
func hide_tooltip():
	visible = false
