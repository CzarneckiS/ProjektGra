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
var move_target = Vector2.ZERO
var original_move_target = Vector2.ZERO #move target zapisywany przy algorytmie omijania przeszkód 
#numerek odpowiada pozycji w raycast_array
#moze wymagac wiecej raycastow dla wiekszej precyzji idk tho
@onready var raycast_0 : RayCast2D = $PathfindingRayCasts/RayCast2D1
@onready var raycast_1 : RayCast2D = $PathfindingRayCasts/RayCast2D2
@onready var raycast_2 : RayCast2D = $PathfindingRayCasts/RayCast2D3
@onready var raycast_3 : RayCast2D = $PathfindingRayCasts/RayCast2D4
@onready var raycast_4 : RayCast2D = $PathfindingRayCasts/RayCast2D5
@onready var raycast_5 : RayCast2D = $PathfindingRayCasts/RayCast2D6
@onready var raycast_6 : RayCast2D = $PathfindingRayCasts/RayCast2D7
@onready var raycast_7 : RayCast2D = $PathfindingRayCasts/RayCast2D8
@onready var raycast_array : Array = [
	raycast_0,
	raycast_1,
	raycast_2,
	raycast_3,
	raycast_4,
	raycast_5,
	raycast_6,
	raycast_7,
]

func send_out_raycasts(target_position):
	print("sendin out raycasts")
	for raycast in raycast_array:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			print("raycast %s is colliding" %raycast)
	var raycast_closest_to_move_target : RayCast2D = find_raycast_closest_to_move_target(target_position)
	if raycast_closest_to_move_target.is_colliding():
		var raycast_to_follow : RayCast2D = find_best_raycast_to_follow(raycast_closest_to_move_target)
		print("closest raycast koliduje i jest nim %s"%raycast_closest_to_move_target)
		match raycast_to_follow:
			raycast_0:
				print("South chosen - raycast 0")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_1:
				print("South-East chosen - raycast 1")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_2:
				print("East chosen - raycast 2")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_3:
				print("North-East chosen - raycast 3")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_4:
				print("North chosen - raycast 4")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_5:
				print("North-West chosen - raycast 5")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_6:
				print("West chosen - raycast 6")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
			raycast_7:
				print("South-West chosen - raycast 7")
				if raycast_0.is_colliding():
					print("i do tego koliduje fajnie")
		return raycast_to_follow
	else:
		print("closest raycast NIE koliduje ale jest nim %s" %raycast_closest_to_move_target)
		return null
	#jesli cos stoi nam na przeszkodzie zwroc najlepszy raycast do followowania
	#jesli optymalny raycast nie jest zablokowany zwroc null
func find_raycast_closest_to_move_target(target_position):
	var closest_raycast = raycast_0
	for raycast in raycast_array:
		if (global_position+raycast.target_position).distance_to(target_position) < (global_position+closest_raycast.target_position).distance_to(target_position):
			closest_raycast = raycast
	return closest_raycast
func find_best_raycast_to_follow(closest_raycast : RayCast2D):
	var starting_position = raycast_array.find(closest_raycast)
	var left_raycast_position = starting_position
	var right_raycast_position = starting_position
	var first_open_raycast
	for i in range(4):
		#dodać wybieranie strony w ktora ida, podejmowanie decyzji
		if left_raycast_position - 1 < 0:
			left_raycast_position = 7
		else:
			left_raycast_position -= 1
		if !raycast_array[left_raycast_position].is_colliding():
			print("analizowany raycast NIE koliduje")
			first_open_raycast = raycast_array[left_raycast_position]
			print("w funkcji sprawdzam wybrany raycast %s" %first_open_raycast)
			print("i czy koliduje %s" %first_open_raycast.is_colliding())
			if first_open_raycast.is_colliding():
				pass
			else:
				break
		else:
			print("analizowany raycast kolidował")
		if right_raycast_position + 1 > 7:
			right_raycast_position = 0
		else:
			right_raycast_position += 1
			if !raycast_array[right_raycast_position].is_colliding():
				print("analizowany raycast NIE koliduje")
				first_open_raycast = raycast_array[left_raycast_position]
				print("w funkcji sprawdzam wybrany raycast %s" %first_open_raycast)
				print("i czy koliduje %s" %first_open_raycast.is_colliding())
				if first_open_raycast.is_colliding():
					pass
				else:
					break
			else:
				print("analizowany raycast kolidował")
	return first_open_raycast
	
func _process(_delta: float) -> void:
	pass
func hit(_damage, _damage_source):
	pass



func _on_attack_timer_timeout() -> void:
	can_attack = true
