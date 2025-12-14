extends Node

var human_warrior_kill_count = 0
var human_archer_kill_count = 0
var human_mage_kill_count = 0

var skill_unlock_handler

enum Event{
	ENTITY_DIED,
	WAVE_CLEARED,
	SKILL_UPDATED
}

var achievement_list : Dictionary = {
	"default_unlock": true,
	"mages_killed": false,
	"skeletons_summoned": false,
	"level_5_skill_unlocked": false,
	"wave_10_reached": false,
	"boss_killed": false
}

func _ready() -> void:
	print("template")
	print(OS.has_feature("template"))
	create_save_directory()
	load_game()
	skill_unlock_handler = SkillUnlockHandler.new()

func achievement_update(event : Event, entity) -> void :
	match event:
		Event.ENTITY_DIED:
			match entity:
				Tags.UnitTag.HUMAN_WARRIOR:
					human_warrior_kill_count += 1
				Tags.UnitTag.HUMAN_ARCHER:
					human_archer_kill_count += 1
				Tags.UnitTag.HUMAN_MAGE:
					human_mage_kill_count += 1
					if human_mage_kill_count >= 5:
						achievement_list.mages_killed = true
		Event.WAVE_CLEARED:
			pass
		Event.SKILL_UPDATED:
			match entity.skill_name:
				"skeleton_warrior":
					if entity.skill_level >= 3:
						achievement_list.skeletons_summoned = true
						save_game()
#na przyszlosc ladniejsza funkcja od unlockowania
func unlock_achievement(achievement):
	if !achievement:
		achievement = true
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
	achievement_list = json.data
	
func save_game(): #potencjalnie do przeniesienia do osobnej klasy / zrobienia oddzielnej funkcji dla achievementow
	var path
	if OS.has_feature("template"):
		path = OS.get_executable_path().get_base_dir().path_join("saves/savegame.json")
	else:
		path = "res://saves/savegame.json"
	print("path")
	print(path)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(achievement_list)
	save_file.store_line(json_string)
	print(save_file)
