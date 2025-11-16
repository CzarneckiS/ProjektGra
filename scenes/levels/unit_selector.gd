extends Node2D

var attack_move_input: bool = false
var dragging: bool = false #czy trzymamy lewy przycisk myszy
var drag_start = Vector2.ZERO #pozycja startowa rysowania selection box
var select_box: Rect2 #prostokąt, którym zaznaczamy jednostki
var x_min #koordynaty do tworzenia prostokąta
var y_min

func _process(_delta: float) -> void:
	if dragging: #kiedy trzymasz lewy przycisk myszy
		if drag_start.is_equal_approx(get_global_mouse_position()): #jeśli nie ruszyłeś myszką
			select_box = Rect2(get_global_mouse_position(), Vector2.ZERO)#nie rysuj prostokąta
			return
		x_min = min(drag_start.x, get_global_mouse_position().x) #wyznaczanie rozmiarów prostokąta
		y_min = min(drag_start.y, get_global_mouse_position().y)
		select_box = Rect2(x_min, y_min,
			max(drag_start.x, get_global_mouse_position().x) - x_min,
			max(drag_start.y, get_global_mouse_position().y) - y_min)
		update_selected_units() #aktualizuj selectowane jednostki
		queue_redraw() #Odśwież grafikę prostokąta

func _unhandled_input(event: InputEvent) -> void: #sprawdza left click
	if attack_move_input:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: #kiedy zaczniesz trzymać left click
			dragging = true
			drag_start = get_global_mouse_position()
		else: #kiedy go puścisz
			dragging = false
			if drag_start.is_equal_approx(get_global_mouse_position()): #jeśli nie ruszyłeś myszką
				select_box = Rect2(get_global_mouse_position(), Vector2.ZERO) #nie rysuj prostokąta
				return
			print('updatuje jednostki')
			update_selected_units() #kiedy puścisz left click zaktualizuj selectowane jednostki
			queue_redraw() #Odśwież grafikę prostokąta

#Wbudowana metoda, która generuje grafikę. Wywoływana w queue_redraw()
func _draw() -> void:
	if dragging == false: #kiedy nie trzymasz left clicka, przestań rysować prostokąt
		return
	draw_rect(select_box, Color(0.0, 0.808, 0.0, 0.42)) #narysuj prostokąt
	draw_rect(select_box, Color(0.0, 0.808, 0.0, 1.0), false, 2.0) #narysuj border
	
#Funkcja selectowania jednostek
func update_selected_units():
	#nie podoba mi sie juz ta funkcja, nie chce dodawac jednostek W TRAKCIE rysowania selection boxa
	#do zmiany na przyszlosc - w trakcie rysowania tylko highlightuj, select przy puszczeniu LMB
	var selected := []
	for unit in get_tree().get_nodes_in_group('Selectable'): #przeszukaj wszystkie sojusznicze jednostki
		if unit.is_in_selection_box(select_box): #sprawdź czy są w selection box
			unit.select() #zaznacz je
			selected.append(unit)
		else:
			unit.deselect() #jak nie są to je odznacz
	Globals.units_selection_changed.emit(selected)
	#
#func update_selected_units():
	#var selected: Array = []
#
	#for unit in get_tree().get_nodes_in_group("Selectable"):
		#if unit.is_in_selection_box(select_box):
			## znajdź główny node jednostki (np. SkeletonWarrior) — czyli taki, który ma metodę select()
			#var root_unit = unit
			#while root_unit.get_parent() and not root_unit.has_method("select") and root_unit.get_parent() != get_tree().root:
				#root_unit = root_unit.get_parent()
#
			#if root_unit.has_method("select"):
				#root_unit.select()
#
				#if root_unit not in selected:
					#selected.append(root_unit)
		#else:
			#if unit.has_method("deselect"):
				#unit.deselect()
#
	#Globals.units_selection_changed.emit(selected)
