extends StaticBody2D
var units_under : int = 0
func _ready() -> void:
	$Area2D.connect("body_entered", _on_area_2d_body_entered)
	$Area2D.connect("body_exited", _on_area_2d_body_exited)
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("i have been entered")
	units_under += 1
	print(units_under)
	#if $Sprite2D.modulate
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.5, 0.5)


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("i have been exited")
	units_under -= 1
	print(units_under)
	if units_under <= 0:
		#if $Sprite2D.modulate == Color(1.0, 1.0, 1.0, 1.0):
		var tween = create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 1, 0.5)
