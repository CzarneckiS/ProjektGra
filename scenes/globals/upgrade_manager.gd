extends Node

var all_skeleton_warrior_upgrades: Dictionary = {}
var unlocked_skeleton_warrior_upgrades: Dictionary = {}

var fireball = preload("res://resources/fireball.tres")
var heal = preload("res://resources/heal.tres")
var thunderbolt = preload("res://resources/thunderbolt.tres")

#func _ready():
	#add_spell(fireball)
	#add_spell(heal)
	#add_spell(thunderbolt)
	#unlock_spell(fireball)
	##ZROBIC UPGRADY JAKO RESOURCE????
#func add_spell(spell):
	#all_spells[spell] = all_spells.size()
#
#func unlock_spell(spell_name):
	#if !(spell_name in unlocked_spells):
		#unlocked_spells[spell_name] = unlocked_spells.size()
#
#func get_spell() -> Array:
	#var available_spells: Array = []
	#var spells_to_show: Array = []
	#for spell in all_spells:
		#if spell not in unlocked_spells:
			#available_spells.append(spell)
	#for spell in available_spells:
		#if spell not in spells_to_show:
			#spells_to_show.append(spell)
	#return spells_to_show
