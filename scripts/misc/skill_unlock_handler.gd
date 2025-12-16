class_name SkillUnlockHandler

var skill_unlock_dictionary : Dictionary = {
	Skills.fireball: "default_unlock",
	Skills.heal: "wave_10_reached",
	Skills.thunderbolt: "mages_killed",
	Skills.unit_on_hit_poison: "wave_10_reached",
	Skills.unit_stat_up_attack_up: "wave_10_reached",
	Skills.unit_death_timer: "default_unlock", #kiedy umrze duzo naszych jednostek
	Skills.player_skeleton_warrior: "default_unlock",
	Skills.player_skeleton_mage: "skeletons_summoned"
}
func update_skill_unlock_handler():
	#taka funkcja bo bool jest przekazywany przez value, nie reference
	#moze uda sie zrobic to ladniej zeby nie trzeba bylo CALEGO dictionary ciagle przepisywac?
	#ale nie mam pomyslu narazie
	#to, co odblokowuje dany achievement jest temporary :)
	skill_unlock_dictionary = {
	Skills.fireball: "default_unlock",
	Skills.heal: "wave_10_reached",
	Skills.thunderbolt: "mages_killed",
	Skills.unit_on_hit_poison: "wave_10_reached",
	Skills.unit_stat_up_attack_up: "wave_10_reached",
	Skills.unit_death_timer: "default_unlock", #kiedy umrze duzo naszych jednostek
	Skills.player_skeleton_warrior: "default_unlock",
	Skills.player_skeleton_mage: "skeletons_summoned"
}

func handle_unlocked_skills():
	for skill in skill_unlock_dictionary:
		if Achievements.achievement_list[skill_unlock_dictionary[skill]]:
			#print("skill unlock")
			#print(skill.skill_name)
			Skills.add_skill(skill)
