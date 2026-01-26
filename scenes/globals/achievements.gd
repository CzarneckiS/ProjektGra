extends Node



var player_stats: Dictionary = {
	"human_warrior_kill_count": 0,
	"human_archer_kill_count": 0,
	"human_mage_kill_count": 0,
	"skeleton_warriors_summoned": 0,
	"skeleton_mages_summoned": 0,
	"flowers_collected": 0
}
var skill_unlock_handler
signal achievement_unlocked(achievement_key)

enum Event{
	ENTITY_DIED,
	WAVE_REACHED,
	SKILL_UPDATED,
	FLOWER_COLLECTED,
	UNIT_SUMMONED
}

var achievement_list : Dictionary = {
	"default_unlock": true, #jako jedyny true bo odnosi sie do skilli odblokowanych na start
	"units_killed_50": false,
	"units_killed_100": false,
	"mages_killed": false,
	"skeletons_summoned": false,
	"army_size_reached": false,
	"flowers_collected": false,
	"level_3_skill_unlocked": false,
	"wave_5_reached": false,
	"wave_10_reached": false,
	"boss_wave_reached": false,
	"boss_killed": false
}

var achievement_description_list : Dictionary = {
	"default_unlock": "",
	"units_killed_50": "Kill 50 enemies",
	"units_killed_100": "Kill 100 enemies",
	"mages_killed": "Kill 50 mages",
	"skeletons_summoned": "Summon 25 units",
	"army_size_reached": "Create an army of 5 units",
	"flowers_collected": "Collect 5 flowers",
	"level_3_skill_unlocked": "Upgrade a skill to level 3",
	"wave_5_reached": "Reach the 5th wave",
	"wave_10_reached": "Reach the 10th wave",
	"boss_wave_reached": "Reach the Boss wave",
	"boss_killed": "Defeat the Boss!"
}

func _process(delta: float) -> void:
	#print(achievement_description_list.get("skeletons_summoned"))
	#for skill in skill_unlock_handler.skill_unlock_dictionary:
		#print(skill_unlock_handler.skill_unlock_dictionary[skill])
	pass #do debuggowania

func _ready() -> void:
	#save_game() #TEMPORARY, DO WYWALENIA
	print("template: %s" %OS.has_feature("template"))
	create_save_directory() #jesli template:  build exportowany do pliku .exe
	load_game()
	skill_unlock_handler = SkillUnlockHandler.new()
	#w main menu pobieramy handler i uzywamy jego funkcji do dodania odblokowanych skilli do puli 

func achievement_update(event : Event, entity) -> void :
	match event:
		Event.ENTITY_DIED:
			match entity:
				Tags.UnitTag.BOSS:
					unlock_achievement("boss_killed")
				Tags.UnitTag.HUMAN_WARRIOR:
					player_stats["human_warrior_kill_count"] += 1
				Tags.UnitTag.HUMAN_ARCHER:
					player_stats["human_archer_kill_count"] += 1
				Tags.UnitTag.HUMAN_MAGE:
					player_stats["human_mage_kill_count"] += 1
					if player_stats["human_mage_kill_count"] >= 5:
						unlock_achievement("mages_killed")
			if player_stats["human_archer_kill_count"] + player_stats["human_mage_kill_count"] + player_stats["human_warrior_kill_count"] >= 50:
				unlock_achievement("units_killed_50")
			if player_stats["human_archer_kill_count"] + player_stats["human_mage_kill_count"] + player_stats["human_warrior_kill_count"] >= 100:
				unlock_achievement("units_killed_100")
		Event.WAVE_REACHED:
			match entity:
				5:
					unlock_achievement("wave_5_reached")
				10:
					unlock_achievement("wave_10_reached")
				20:
					unlock_achievement("boss_wave_reached")
		Event.SKILL_UPDATED:
			if entity.skill_level >= 3:
				unlock_achievement("level_3_skill_unlocked")
			match entity.skill_name:
				"skeleton_warrior":
					if entity.skill_level >= 5:
						unlock_achievement("army_size_reached")
		Event.FLOWER_COLLECTED:
			player_stats["flowers_collected"] += 1
			if player_stats["flowers_collected"] >= 5:
				unlock_achievement("flowers_collected")
		Event.UNIT_SUMMONED:
			match entity:
				Tags.UnitTag.SKELETON_WARRIOR:
					player_stats["skeleton_warriors_summoned"] += 1
				Tags.UnitTag.SKELETON_MAGE:
					player_stats["skeleton_mages_summoned"] += 1
			if player_stats["skeleton_mages_summoned"] + player_stats["skeleton_warriors_summoned"] >= 25:
				unlock_achievement("skeletons_summoned")
						
func unlock_achievement(achievement):
	if !achievement_list.has(achievement):
		print("Achievement doesnt exist: " + achievement)
		return
		
	if achievement_list[achievement]:
		return
		
	achievement_list[achievement] = true
	
	
	print("$EMITTING ACHIEVEMENT:", achievement)
	emit_signal("achievement_unlocked", achievement)
	save_game()
		
func create_save_directory():
	if OS.has_feature("template"):
		var path = OS.get_executable_path().get_base_dir().path_join("saves")
		if !FileAccess.file_exists(path):
			DirAccess.make_dir_absolute(path)

func load_game():
	var path
	if OS.has_feature("template"):
		path = OS.get_executable_path().get_base_dir().path_join("saves/savegame.json")
	else:
		path = "res://saves/savegame.json"
	var save_file = FileAccess.open(path, FileAccess.READ)
	if !save_file:
		print("No save file found!")
		return
	var json_string = save_file.get_line()
	var json = JSON.new()
	var _parse_result = json.parse(json_string)
	var save_data = json.data
	achievement_list = save_data.get("achievement_list_dict", achievement_list)
	player_stats = save_data.get("player_stats_dict", player_stats)
	
	
func save_game(): #potencjalnie do przeniesienia do osobnej klasy / zrobienia oddzielnej funkcji dla achievementow
	var path
	var save_data: Dictionary = {
	"achievement_list_dict" : achievement_list,
	"player_stats_dict": player_stats
	}
	if OS.has_feature("template"):
		path = OS.get_executable_path().get_base_dir().path_join("saves/savegame.json")
	else:
		path = "res://saves/savegame.json"
	print("path")
	print(path)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	print(save_file)
