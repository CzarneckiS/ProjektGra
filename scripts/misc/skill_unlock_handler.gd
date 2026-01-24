class_name SkillUnlockHandler

var skill_unlock_dictionary : Dictionary = {
	Skills.fireball: "default_unlock",
	Skills.heal: "default_unlock",
	Skills.thunderbolt: "default_unlock",
	Skills.player_skeleton_warrior: "default_unlock",
	Skills.player_skeleton_mage: "army_size_reached",
	Skills.icewall: "boss_wave_reached",
	Skills.blackhole: "mages_killed",
	Skills.tornado: "boss_killed",
	Skills.unit_on_hit_bleed: "level_3_skill_unlocked",
	Skills.unit_on_hit_lifesteal: "skeletons_summoned",
	Skills.unit_stat_up_attack_up: "units_killed_50",
	Skills.unit_stat_up_health_up: "wave_5_reached",
	Skills.unit_unholy_frenzy: "units_killed_100",
	Skills.player_life_on_kill: "wave_10_reached",
	Skills.player_summon_respawn_time_up: "flowers_collected"
}
func update_skill_unlock_handler():
	#taka funkcja bo bool jest przekazywany przez value, nie reference
	#moze uda sie zrobic to ladniej zeby nie trzeba bylo CALEGO dictionary ciagle przepisywac?
	#ale nie mam pomyslu narazie
	#to, co odblokowuje dany achievement jest temporary :)
	skill_unlock_dictionary = {
	Skills.fireball: "default_unlock",
	Skills.heal: "default_unlock",
	Skills.thunderbolt: "default_unlock",
	Skills.player_skeleton_warrior: "default_unlock",
	Skills.player_skeleton_mage: "army_size_reached",
	Skills.icewall: "boss_wave_reached",
	Skills.blackhole: "mages_killed",
	Skills.tornado: "boss_killed",
	Skills.unit_on_hit_bleed: "level_3_skill_unlocked",
	Skills.unit_on_hit_lifesteal: "skeletons_summoned",
	Skills.unit_stat_up_attack_up: "units_killed_50",
	Skills.unit_stat_up_health_up: "wave_5_reached",
	Skills.unit_unholy_frenzy: "units_killed_100",
	Skills.player_life_on_kill: "wave_10_reached",
	Skills.player_summon_respawn_time_up: "flowers_collected"
}

func handle_unlocked_skills():
	for skill in skill_unlock_dictionary:
		if Achievements.achievement_list[skill_unlock_dictionary[skill]]:
			#print("skill unlock")
			#print(skill.skill_name)
			Skills.add_skill(skill)
