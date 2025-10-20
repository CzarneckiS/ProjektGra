extends CharacterBody2D

class_name UnitParent

var health = 100

func _process(_delta: float) -> void:
	pass

func hit(damage) -> void:
	#le hit function, pobiera dane od tego co zaatakowalo zeby hp spadlo o dmg ;3
	health -= damage
