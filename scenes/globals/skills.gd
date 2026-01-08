extends Node

var all_skills: Array = [] #Wszystkie skille ktore mozemy zdobyc w trakcie runa (achievement odblokowany)
var unlocked_skills: Array = [] #Wszystkie skille ktore wybralismy przy level upie


var fireball = preload("res://resources/fireball.tres")
var heal = preload("res://resources/heal.tres")
var thunderbolt = preload("res://resources/thunderbolt.tres")
var unit_on_hit_bleed = preload("res://resources/unit_on_hit_bleed.tres")
var unit_on_hit_lifesteal = preload("res://resources/unit_on_hit_lifesteal.tres")
var unit_stat_up_attack_up = preload("res://resources/unit_stat_up_attack_up.tres")
var unit_stat_up_health_up = preload("res://resources/unit_stat_up_health_up.tres")
var unit_unholy_frenzy = preload("res://resources/unit_unholy_frenzy.tres")
var player_skeleton_warrior = preload("res://resources/player_skeleton_warrior.tres")
var player_skeleton_mage = preload("res://resources/player_skeleton_mage.tres")
var player_summon_respawn_time_up = preload("res://resources/player_summon_respawn_time_up.tres")
var player_life_on_kill = preload("res://resources/player_life_on_kill.tres")


func add_skill(skill):
	if skill not in all_skills:
		all_skills.append(skill)

func unlock_skill(skill):
	if !(skill in unlocked_skills):
		unlocked_skills.append(skill)
	else:
		skill.skill_level += 1
	for unit in get_tree().get_nodes_in_group("Allied"):
		unit.handle_skill_update(skill)

func reset_unlocked_skills():
	for skill in unlocked_skills:
		skill.skill_level = 1
	unlocked_skills = []

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
