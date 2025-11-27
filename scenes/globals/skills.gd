extends Node
#SKILL - DOWOLNA UMIEJETNOSC / BUFF DLA JEDNOSTKI
#SPELL - TO CO CASTUJE NASZA POSTAC
#ALL SPELLS = SKILLS BUT ALL SKILLS =/= SPELLS
var all_skills: Array = []
var unlocked_skills: Array = []


var fireball = preload("res://resources/fireball.tres")
var heal = preload("res://resources/heal.tres")
var thunderbolt = preload("res://resources/thunderbolt.tres")
var unit_on_hit_poison = preload("res://resources/unit_on_hit_poison.tres")
var unit_stat_up_attack_up = preload("res://resources/unit_stat_up_attack_up.tres")
var unit_death_timer = preload("res://resources/unit_death_timer.tres")
var player_skeleton_warrior = preload("res://resources/player_skeleton_warrior.tres")
var player_skeleton_mage = preload("res://resources/player_skeleton_mage.tres")


func add_skill(skill):
	all_skills.append(skill)

func unlock_skill(skill):
	if !(skill in unlocked_skills):
		unlocked_skills.append(skill)
	else:
		skill.skill_level += 1
	for unit in get_tree().get_nodes_in_group("Allied"):
		unit.handle_skill_update(skill)

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
