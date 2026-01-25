extends Control
class_name SkillTooltip

@onready var label: RichTextLabel = $Text

var descriptions = {
	"Attack": "[Z] Attack enemies in range.",
	"Hold": "[C] Hold position and defend.",
	"Move": "[RMB] Move to selected location.",
	"Stop": "[X] Stop all current actions.",
	"HPBar": "Health: If this reaches zero, you lose.",
	"XPBar": "Experience: Collect to unlock new skills.",
	"PlayerLvl": "Hero Level: Reflects your current strength. Higher levels unlock stronger abilities.",
	
	1: "[Q] ",
	2: "[E] ",
	3: "[R] ",
	4: "[F] "
}

func show_text(icon_name):
	label.text 	= icon_name + "\n" + descriptions.get(icon_name, "")
	visible = true
	
func show_spell_text(skill: Skill, _order_number = null):
	if skill.has_method("get_skill_name"):
		label.text = descriptions.get(_order_number, "") + skill.get_skill_name() + "\n" + skill.tooltip_desc()
	else:
		label.text = descriptions.get(_order_number, "") + skill.skill_name + "\n" + skill.tooltip_desc()
	visible = true
		
func show_bar_text(bar_name):
	label.text 	= descriptions.get(bar_name, "")
	visible = true
	
func show_player_lvl_text():
	label.text 	= descriptions.get("PlayerLvl", "")
	visible = true
	
func hide_tooltip():
	visible = false
