extends CharacterBody2D
class_name UnitParent


var max_health 
var health 
var bar_style = StyleBoxFlat.new()
var icon_texture

var can_attack: bool = true
var status_effects_array = []
signal took_damage(damage, unit)
signal unit_died(unit)

# warior=1 mage=3
var unit_hud_order

func _process(_delta: float) -> void:
	pass
func hit(_damage, _damage_source):
	pass



func _on_attack_timer_timeout() -> void:
	can_attack = true
