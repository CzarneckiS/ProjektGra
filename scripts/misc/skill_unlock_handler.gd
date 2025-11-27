class_name SkillUnlockHandler

var skill_unlock_dictionary : Dictionary = {
	#to, co odblokowuje dany achievement jest temporary :)
	Skills.fireball: Achievements.achievement_list.default_unlock,
	Skills.heal: Achievements.achievement_list.wave_10_reached,
	Skills.thunderbolt: Achievements.achievement_list.mages_killed,
	Skills.unit_on_hit_poison: Achievements.achievement_list.wave_10_reached,
	Skills.unit_stat_up_attack_up: Achievements.achievement_list.wave_10_reached,
	Skills.unit_death_timer: Achievements.achievement_list.default_unlock, #kiedy umrze duzo naszych jednostek
	Skills.player_skeleton_warrior: Achievements.achievement_list.default_unlock,
	Skills.player_skeleton_mage: Achievements.achievement_list.skeletons_summoned
}

func _init() -> void:
	handle_unlocked_skills()
	#trzeba jakos zrobic zeby przed kazdym runem to sie robilo, nie po wlaczeniu gry ! :)

func handle_unlocked_skills():
	for skill in skill_unlock_dictionary:
		if skill_unlock_dictionary[skill]:
			Skills.add_skill(skill)
