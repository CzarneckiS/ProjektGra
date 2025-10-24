extends Control

# DO POPRAWIENIA - KIEDY SIE RUSZAMY I SELECTUJEMY JEDNOCZESNIE ROBIA SIE DZIWNE RZECZY
# PEWNIE TRZEBA UPDATOWAC ROZMIAR I REDRAWOWAC W PROCESIE NIE W INPUCIE
# ogolnie ten selecting jest jakis kompletnie zjebany
# trzeba bedzie go ostro poprawic, moze nawet napisac od zera

var dragging: bool = false
var drag_start = Vector2.ZERO
var select_box: Rect2
var x_min
var y_min

	#MOZNA POPRAWIC UZYWAJAC WORLD QUERY
	#jak bede mial czas to poprawie
	#zaznaczanie jednostek pojedynczo znajduje sie w scenach allied jednostek
	#RYSOWANIE JEST ZJEBANE, OBOWIAZKOWO DO POPRAWY
	#damn, jakis chujowy tutorial ogladalem, kompletnie sie to sypie  
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
		else:
			dragging = false
			if drag_start.is_equal_approx(get_global_mouse_position()):
				select_box = Rect2(get_global_mouse_position(), Vector2.ZERO)
			update_selected_units() 
			queue_redraw()
	elif dragging and event is InputEventMouseMotion:
		x_min = min(drag_start.x, get_global_mouse_position().x)
		y_min = min(drag_start.y, get_global_mouse_position().y)
		select_box = Rect2(x_min, y_min,
			max(drag_start.x, get_global_mouse_position().x) - x_min,
			max(drag_start.y, get_global_mouse_position().y) - y_min)
		update_selected_units()
		queue_redraw()
func _draw() -> void:
	if dragging == false:
		return
	draw_rect(select_box, Color(0.0, 0.808, 0.0, 0.42))
	draw_rect(select_box, Color(0.0, 0.808, 0.0, 1.0), false, 2.0)
func update_selected_units():
	for unit in get_tree().get_nodes_in_group('Selectable'):
		if unit.is_in_selection_box(select_box):
			unit.select()
		else:
			unit.deselect()
