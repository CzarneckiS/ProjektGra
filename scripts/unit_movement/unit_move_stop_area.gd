class_name UnitMovementStopAreaClass
extends Area2D

var unit_array : Array = []
var units_inside : Array = []
var units_reached_target = 0
func _ready() -> void:
	connect("body_entered",_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body in unit_array:
		units_reached_target += 1
		check_if_can_stop(body)
		units_inside.append(body)
		$CollisionShape2D.shape.radius += 15 #10 + sqrt(800*units_reached_target)

func check_if_can_stop(body : Node2D):
	if units_inside.size() == 0:
		body.state_machine.set_state(body.state_machine.states.idle)
	else:
		for unit in units_inside:
			if body.global_position.distance_to(unit.global_position) < 60 and unit != body:
				body.state_machine.set_state(body.state_machine.states.idle)
	if body.state_machine.state != body.state_machine.states.idle:
		await body.get_tree().create_timer(0.1).timeout
		if body:
			check_if_can_stop(body)
		
#connect them, kiedy sie zatrzymuja niech wysylaja sygnal yada yada
