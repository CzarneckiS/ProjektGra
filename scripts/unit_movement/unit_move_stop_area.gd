class_name UnitMovementStopAreaClass
extends Area2D

var unit_array : Array = []
var units_inside : Array = []
var units_reached_target = 0
const STOP_DISTANCE = 60
func _ready() -> void:
	connect("body_entered",_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body in unit_array:
		units_reached_target += 1
		check_if_can_stop(body)

func check_if_can_stop(body : Node2D):
	if body:
		if body in units_inside:
			return
		if units_inside.size() == 0:
			stop_body(body)
		else:
			for unit in units_inside:
				if unit:
					if body.global_position.distance_to(unit.global_position) < STOP_DISTANCE and unit != body:
						stop_body(body)
						return
			if body.state_machine.state != body.state_machine.states.idle:
				await body.get_tree().create_timer(0.3,false).timeout
				if body:
					check_if_can_stop(body)

func stop_body(body : Node2D):
	body.state_machine.set_state(body.state_machine.states.idle)
	units_inside.append(body)
	$CollisionShape2D.shape.radius += 15 #10 + sqrt(800*units_reached_target)
#connect them, kiedy sie zatrzymuja niech wysylaja sygnal yada yada
