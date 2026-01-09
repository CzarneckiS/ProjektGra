extends Node

#moze w przyszlosci zmienic na dictionary
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
	"default_unlock": true, #jako jedyny true bo odnosi sie do skilli odblokowanych na start
	"mages_killed": true,
	"skeletons_summoned": true,
	"level_5_skill_unlocked": true,
	"wave_10_reached": true,
	"boss_wave_reached": true,
	"boss_killed": true
}

var achievement_description_list : Dictionary = {
	"default_unlock": "",
	"mages_killed": "Zabij 100 magów",
	"skeletons_summoned": "Przyzwij jednocześnie 5 jednostek",
	"level_5_skill_unlocked": "Ulepsz umiejętność do poziomu 5",
	"wave_10_reached": "Dotrzyj do fali 10",
	"boss_wave_reached": "Dotrzyj do Bossa",
	"boss_killed": "Pokonaj Bossa"
}

func _process(delta: float) -> void:
	#print(achievement_description_list.get("skeletons_summoned"))
	#for skill in skill_unlock_handler.skill_unlock_dictionary:
		#print(skill_unlock_handler.skill_unlock_dictionary[skill])
	pass #do debuggowania

func _ready() -> void:
	save_game() #TEMPORARY, DO WYWALENIA
	print("template")
	print(OS.has_feature("template"))
	create_save_directory() #jesli template:  build exportowany do pliku .exe
	load_game()
	skill_unlock_handler = SkillUnlockHandler.new()
	#w main menu pobieramy handler i uzywamy jego funkcji do dodania odblokowanych skilli do puli 

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
						unlock_achievement("mages_killed")
		Event.WAVE_CLEARED:
			pass
		Event.SKILL_UPDATED:
			match entity.skill_name:
				"skeleton_warrior":
					if entity.skill_level >= 3:
						unlock_achievement("skeletons_summoned")
#na przyszlosc ladniejsza funkcja od unlockowania
func unlock_achievement(achievement):
	print(achievement_list.get(achievement))
	if !achievement_list.get(achievement):
		print("unlocking skeleton mage")
		achievement_list.set(achievement, true)
		print(achievement_list.get(achievement))
		print("im finding this key:")
		print(skill_unlock_handler.skill_unlock_dictionary.find_key(achievement))
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
