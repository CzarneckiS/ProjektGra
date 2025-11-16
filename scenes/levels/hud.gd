extends Control

@onready var main_health_bar: ProgressBar = $HealthBar 
@onready var main_damage_bar: ProgressBar = $DamageBar
@onready var xp_bar: ProgressBar = $ExpBar
@onready var xp_gain_bar: ProgressBar = $ExpGainBar
@onready var player_level: Label = $LabelPlayerLevel
@onready var units_panel: GridContainer = $UnitsPanel

var hp_bar_style = StyleBoxFlat.new()
var xp_bar_style = StyleBoxFlat.new()
var unit_slots: Array = []
var selected_units: Array = []
var groups_in_selection: Array = []
var current_group_index: int = -1
var unique_orders_in_selection: Array = []
var ctrl_active  = false

func _ready() -> void:
	Globals.ui_hp_update_requested.connect(update_hp_bar)
	Globals.ui_exp_update_requested.connect(update_exp_bar)
	Globals.unit_died.connect(_on_unit_died)
	Globals.units_selection_changed.connect(update_units_panel)
	
	for child in units_panel.get_children():
		if child is TextureButton:
			unit_slots.append(child)
			
	main_health_bar.max_value = Globals.health
	main_health_bar.value = Globals.health
	main_damage_bar.max_value = Globals.health
	main_damage_bar.value = Globals.health
	main_health_bar.visible = true
	main_damage_bar.visible = true
	
	xp_bar.max_value = Globals.xp_to_level
	xp_bar.value = Globals.accumulated_xp
	xp_gain_bar.max_value = Globals.xp_to_level
	xp_gain_bar.value = Globals.accumulated_xp
	xp_bar.visible = true
	xp_gain_bar.visible = true
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select_next_group"):
		_cycle_unit_group()

	if event.is_action_pressed("ui_ctrl"):
		ctrl_active = true
		if groups_in_selection.is_empty():
			return

		for unit in selected_units:
			if unit in groups_in_selection:
				unit.select()
			else:
				unit.deselect()
		return

	#po puszczeniu ctrl wraca selekcja
	if event.is_action_released("ui_ctrl"):
		ctrl_active = false
		for unit in selected_units:
			unit.select()
		return

func update_hp_bar():
	print(Globals.health)
	main_health_bar.value = Globals.health
	
	var main_health_tween = create_tween()
	main_health_tween.tween_property(main_damage_bar, "value", Globals.health, 0.2)
	main_health_tween.set_trans(Tween.TRANS_SINE)
	main_health_tween.set_ease(Tween.EASE_OUT)
	
func update_exp_bar():
	var xp_tween = create_tween()
	xp_tween.tween_property(xp_gain_bar, "value", Globals.accumulated_xp, 0.7)
	xp_tween.set_trans(Tween.TRANS_SINE)
	xp_tween.set_ease(Tween.EASE_OUT)
	
	player_level.text = "LVL: %d" % Globals.level
	
func update_units_panel(new_units: Array) -> void:
	#sortowanie ikonek w hudzie
	selected_units = new_units
	selected_units.sort_custom(func(a, b): return a.unit_hud_order < b.unit_hud_order)
	
	for slot in unit_slots:
		slot.custom_minimum_size = Vector2(50, 50)
		
		if slot.is_connected("pressed", Callable(self, "_on_unit_slot_pressed")):
			slot.disconnect("pressed", Callable(self, "_on_unit_slot_pressed"))
		slot.set_meta("unit_ref", null)
		
		var border = slot.get_node_or_null("Border")
		if border:
			border.visible = false
		
		var texture_rect = slot.get_node_or_null("Icon")
		if texture_rect:
			texture_rect.texture = preload("res://sprites/UnitEmptyIcon.png")
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
	for i in range(min(selected_units.size(), unit_slots.size())):
		var unit = selected_units[i]
		var slot = unit_slots[i]
		
		var texture_rect = slot.get_node("Icon")
		if texture_rect:
			if unit.icon_texture != "" and ResourceLoader.exists(unit.icon_texture):
				texture_rect.texture = load(unit.icon_texture)
			else:
				texture_rect.texture = preload("res://sprites/UnitDoesntLinkedIcon.png")
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		slot.set_meta("unit_ref", unit)
		slot.connect("pressed", Callable(self, "_on_unit_slot_pressed").bind(slot))
		
		#jak mamy border to unity są podłasne ctrl i znajdują się w groups_in_selection
		var border = slot.get_node_or_null("Border")
		if border:
			border.visible = true
			if unit in groups_in_selection:
				border.modulate = Color("dcdcdc")

	#dzielimy na grupy dla przesunięcia(tab lub myszką) i ctrl
	unique_orders_in_selection = []
	for unit in selected_units:
		if not unique_orders_in_selection.has(unit.unit_hud_order):
			unique_orders_in_selection.append(unit.unit_hud_order)
	unique_orders_in_selection.sort()
	current_group_index = -1

func selection_change() -> void:
	if groups_in_selection.is_empty():
		for unit in selected_units:
			unit.select()
		return

	for unit in selected_units:
		if unit in groups_in_selection:
			unit.select()
		else:
			unit.deselect()

func _on_unit_slot_pressed(slot: TextureButton) -> void:
	if slot.get_meta("unit_ref") == null:
		return
		
	var units_buffer: Array = []
	for u in selected_units:
		if u.unit_hud_order == slot.get_meta("unit_ref").unit_hud_order:
			units_buffer.append(u)
			 		
	if groups_in_selection != units_buffer:
		groups_in_selection = units_buffer.duplicate()
		for i in range(selected_units.size()):
			var border = unit_slots[i].get_node_or_null("Border")
			if border:
				border.visible = (selected_units[i] in groups_in_selection)
		return
	
	if unique_orders_in_selection.size() >= 2:
		groups_in_selection = units_buffer.duplicate()
		selection_change()
		selected_units = units_buffer.duplicate()
		update_units_panel(selected_units)
		return

	if groups_in_selection.size() > 1:
		groups_in_selection = [slot.get_meta("unit_ref")]
		selection_change()
		selected_units = [slot.get_meta("unit_ref")]
		update_units_panel(selected_units)
		return
	
	selection_change()
	return

func _on_unit_died(unit):
	if unit in selected_units:
		selected_units.erase(unit)
		update_units_panel(selected_units)

func _cycle_unit_group() -> void:
	if unique_orders_in_selection.is_empty():
		return

	current_group_index += 1

	if current_group_index >= unique_orders_in_selection.size():
		current_group_index = -1
		groups_in_selection = selected_units.duplicate()

		for i in range(selected_units.size()):
			var border = unit_slots[i].get_node_or_null("Border")
			if border:
				border.visible = true
		return

	var active_order = unique_orders_in_selection[current_group_index]
	groups_in_selection.clear()

	for i in range(selected_units.size()):
		var unit = selected_units[i]
		var border = unit_slots[i].get_node_or_null("Border")

		if unit.unit_hud_order == active_order:
			groups_in_selection.append(unit)
	
		if border:
			border.visible = (unit.unit_hud_order == active_order)
