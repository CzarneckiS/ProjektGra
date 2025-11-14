extends CharacterBody2D
class_name UnitParent


var max_health 
var health 
var bar_style = StyleBoxFlat.new()
var icon_texture

# warior=1 mage=3
var unit_hud_order

func _process(_delta: float) -> void:
	pass
func hit(_damage, _damage_source):
	pass
