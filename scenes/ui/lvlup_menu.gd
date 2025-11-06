extends Control

@onready var description_1: Label = $Description1
@onready var description_2: Label = $Description2
@onready var description_3: Label = $Description3
@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2
@onready var texture_rect_3: TextureRect = $TextureRect3
var skills_to_show: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_up()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_option_1_pressed() -> void:
	get_tree().paused = false
	Skills.unlock_skill(skills_to_show[0])
	queue_free()   


func _on_option_2_pressed() -> void:
	get_tree().paused = false 
	Skills.unlock_skill(skills_to_show[1])
	queue_free()   


func _on_option_3_pressed() -> void:
	get_tree().paused = false 
	Skills.unlock_skill(skills_to_show[2])
	queue_free()   

func level_up():
	skills_to_show = Skills.get_skill()
	description_1.text = skills_to_show[0].skill_name
	texture_rect.texture = skills_to_show[0].icon
	description_2.text = skills_to_show[1].skill_name
	texture_rect_2.texture = skills_to_show[1].icon
	description_3.text = skills_to_show[2].skill_name
	texture_rect_3.texture = skills_to_show[2].icon
