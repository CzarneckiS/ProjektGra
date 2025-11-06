extends Node
#SKILL - DOWOLNA UMIEJETNOSC / BUFF DLA JEDNOSTKI
#SPELL - TO CO CASTUJE NASZA POSTAC
#ALL SPELLS = SKILLS BUT ALL SKILLS =/= SPELLS
var all_skills: Dictionary = {}
var unlocked_skills: Dictionary = {}

var fireball = preload("res://resources/fireball.tres")
var heal = preload("res://resources/heal.tres")
var thunderbolt = preload("res://resources/thunderbolt.tres")
var unit_on_hit_poison = preload("res://resources/unit_on_hit_poison.tres")

func _ready():
	add_skill(fireball)
	add_skill(heal)
	add_skill(thunderbolt)
	add_skill(unit_on_hit_poison)
	unlock_skill(fireball)
	unlock_skill(unit_on_hit_poison)
	
func add_skill(skill):
	all_skills[skill] = all_skills.size()

func unlock_skill(skill):
	if !(skill in unlocked_skills):
		unlocked_skills[skill] = unlocked_skills.size()
	else:
		skill.skill_level += 1

#DODAC BOOL = CZY OSIAGNELISMY LIMIT SPELL SLOTOW ! ! ! 
func get_skill() -> Array:
	var available_skills: Array = []
	var skills_to_show: Array = []
	for skill in all_skills:
		available_skills.append(skill)
	available_skills.shuffle()
	for i in available_skills.size():
		if i >=3:
			break
		skills_to_show.append(available_skills[i])
	return skills_to_show
