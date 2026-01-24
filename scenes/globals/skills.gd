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
func _physics_process(_delta: float) -> void:
	print("skills:")
	for skill in all_skills:
		print(skill.skill_name)

func unlock_skill(skill):
	if !(skill in unlocked_skills):
		unlocked_skills.append(skill)
		handle_skill_choice_limits()
		if skill.skill_level == 0:
			skill.skill_level = 1
		for unit in get_tree().get_nodes_in_group("Allied"):
			unit.handle_skill_update(skill)
	else:
		skill.skill_level += 1
		if skill.has_method("upgrade_skill"):
			skill.upgrade_skill()

func reset_skills():
	active_skill_slots_limit_reached = false
	passive_skill_slots_limit_reached = false
	for skill in unlocked_skills:
		skill.skill_level = 0
	unlocked_skills = []



var active_skill_slots_limit: int = 4
var passive_skill_slots_limit: int = 4
var active_skill_slots_limit_reached: bool = false
var passive_skill_slots_limit_reached: bool = false
func handle_skill_choice_limits():
	#jesli osiagniemy limit skilli to usuwamy dany typ z dostepnych skilli do wybrania(all_skills)
	var active_skills_chosen: int = 0
	var passive_skills_chosen: int = 0
	if !active_skill_slots_limit_reached: #sprawdzamy ilosc aktywnych skilli
		for skill in unlocked_skills:
			if skill.use_tags.has(Tags.UseTag.ACTIVE):
				active_skills_chosen += 1
		if active_skills_chosen >= active_skill_slots_limit:
			active_skill_slots_limit_reached = true
			#usuwanie
			for _skill in all_skills:
				if _skill in unlocked_skills:
					continue
				if _skill.use_tags.has(Tags.UseTag.ACTIVE):
					all_skills.erase(_skill)
	if !passive_skill_slots_limit_reached:
		for skill in unlocked_skills:
			if !skill.use_tags.has(Tags.UseTag.ACTIVE) and !skill.use_tags.has(Tags.UseTag.SUMMON):
				passive_skills_chosen += 1
		if passive_skills_chosen >= passive_skill_slots_limit:
			passive_skill_slots_limit_reached = true
			#usuwanie
			for _skill in all_skills:
				if _skill in unlocked_skills:
					continue
				if !_skill.use_tags.has(Tags.UseTag.ACTIVE) and !_skill.use_tags.has(Tags.UseTag.SUMMON):
					all_skills.erase(_skill)


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
