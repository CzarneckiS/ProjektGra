extends Control
class_name SkillTooltip

@onready var label: Label = $Text

var descriptions = {
	"Attack": "Attack enemies in range.",
	"Hold": "Hold position and defend.",
	"Move": "Move to selected location.",
	"Stop": "Stop all current actions.",
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
	
func show_spell_text(_skill: Skill, _order_number = null):
	label.text = descriptions.get(_order_number, "") + _skill.skill_name + "\n" + _skill.skill_desc
	visible = true
		
func show_bar_text(bar_name):
	label.text 	= descriptions.get(bar_name, "")
	visible = true
	
func show_player_lvl_text():
	label.text 	= descriptions.get("PlayerLvl", "")
	visible = true
	
func hide_tooltip():
	visible = false
