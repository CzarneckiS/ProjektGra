extends Control

@onready var description_1: Label = $Description1
@onready var description_2: Label = $Description2
@onready var description_3: Label = $Description3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_up()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_option_1_pressed() -> void:
	get_tree().paused = false
	Skills.unlock_spell(Skills.heal)
	for skill in Skills.unlocked_spells:
		print(skill.skill_name)
	queue_free()   


func _on_option_2_pressed() -> void:
	get_tree().paused = false 
	queue_free()   


func _on_option_3_pressed() -> void:
	get_tree().paused = false 
	queue_free()   

func level_up():
	var spells_to_show: Array = Skills.get_spell()
	description_1.text = spells_to_show[0].skill_name
	description_2.text = spells_to_show[1].skill_name
	#description_3.text = spells_to_show[2]
