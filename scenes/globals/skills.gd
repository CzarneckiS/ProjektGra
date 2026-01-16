extends Node

var all_skills: Array = [] #Wszystkie skille ktore mozemy zdobyc w trakcie runa (achievement odblokowany)
var unlocked_skills: Array = [] #Wszystkie skille ktore wybralismy przy level upie

var fireball = preload("res://resources/fireball.tres")
var heal = preload("res://resources/heal.tres")
var thunderbolt = preload("res://resources/thunderbolt.tres")
var icewall = preload("res://resources/iceblock.tres")
var blackhole = preload("res://resources/field.tres")
var tornado = preload("res://resources/tornado.tres")
var unit_on_hit_bleed = preload("res://resources/unit_on_hit_bleed.tres")
var unit_on_hit_lifesteal = preload("res://resources/unit_on_hit_lifesteal.tres")
var unit_stat_up_attack_up = preload("res://resources/unit_stat_up_attack_up.tres")
var unit_stat_up_health_up = preload("res://resources/unit_stat_up_health_up.tres")
var unit_unholy_frenzy = preload("res://resources/unit_unholy_frenzy.tres")
var player_skeleton_warrior = preload("res://resources/player_skeleton_warrior.tres")
var player_skeleton_mage = preload("res://resources/player_skeleton_mage.tres")
var player_summon_respawn_time_up = preload("res://resources/player_summon_respawn_time_up.tres")
var player_life_on_kill = preload("res://resources/player_life_on_kill.tres")

var legendary: float = 0.15
var rare: float = 0.35
var common: float = 0.5
var skill_rarity_table : Dictionary = {
	fireball: common,
	heal: common,
	thunderbolt: rare,
	icewall: rare,
	blackhole: legendary,
	tornado: legendary,
	unit_on_hit_bleed: rare,
	unit_on_hit_lifesteal: rare,
	unit_stat_up_attack_up: rare,
	unit_stat_up_health_up: rare,
	unit_unholy_frenzy: rare,
	player_skeleton_warrior: common,
	player_skeleton_mage: common,
	player_summon_respawn_time_up: rare,
	player_life_on_kill: rare
}

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
	var total_weight = calculate_total_weight() #sprawdzamy laczna wage skilli
	var available_skills: Dictionary = {}
	var skills_to_show: Array = []
	for skill in all_skills: #normalizujemy wage skilli (suma jest rowna 1)
		available_skills[skill] = skill_rarity_table[skill] / total_weight
	while skills_to_show.size() < 3:
		var random_float = randf_range(0,1) #wybieramy numerek od 1 do 0
		for skill in available_skills: #i przechodzimy kolejno po skillach w loot table
			if random_float > available_skills[skill]: #i porownujemy czy numerek odpowiada skillowi
				random_float -= available_skills[skill] #jak jest za duzy to odejmujemy wage skilla
			else: #i przechodzimy dalej
				if skill in skills_to_show: #sprawdzamy czy wylosowalismy powtorke
					break
				else:
					skills_to_show.append(skill) #az numerek jest mniejszy niz waga czyli doszlismy do skilla wylosowanego
					break
	return skills_to_show

func calculate_total_weight() -> float:
	var total_weight = 0
	for skill in all_skills:
		total_weight += skill_rarity_table[skill]
	return total_weight
