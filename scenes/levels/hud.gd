extends Control

@onready var hp_value: Label = $HPValue
@onready var xp_value: Label = $XPValue
@onready var main_damage_bar: ProgressBar = $DamageBar
@onready var xp_gain_bar: ProgressBar = $ExpGainBar
@onready var player_level: Label = $LabelPlayerLevel
@onready var units_panel: GridContainer = $UnitsPanel
@onready var icon_page_1: TextureRect = $HudLeftCorner/IconPage1
@onready var icon_page_2: TextureRect = $HudLeftCorner/IconPage2
@onready var icon_page_3: TextureRect = $HudLeftCorner/IconPage3
@onready var spell_bar: Control = $HudRightCorner
@export var popup_scene: PackedScene = preload("res://scenes/ui/achievements_popup.tscn")
@export var spell_slot_scene: PackedScene = preload("res://scenes/ui/spell_slot.tscn")
@onready var scena_spell_slot_1: SpellSlot = $"ScenaSpellSlot1"
@onready var scena_spell_slot_2: SpellSlot = $"ScenaSpellSlot2"
@onready var scena_spell_slot_3: SpellSlot = $"ScenaSpellSlot3"
@onready var scena_spell_slot_4: SpellSlot = $"ScenaSpellSlot4"
@onready var scena_passive_slot_1: SpellSlot = $ScenaPassiveSlot1
@onready var scena_passive_slot_2: SpellSlot = $ScenaPassiveSlot2
@onready var scena_passive_slot_3: SpellSlot = $ScenaPassiveSlot3
@onready var scena_passive_slot_4: SpellSlot = $ScenaPassiveSlot4
@export var skill_tooltip_scene: PackedScene = preload("res://scenes/ui/tooltip_scene.tscn")
@export var bars_tooltip_scene: PackedScene = preload("res://scenes/ui/tooltip_scene.tscn")
@onready var attack_icon: TextureRect = $AttackIcon
@onready var hold_icon: TextureRect = $HoldIcon
@onready var move_icon: TextureRect = $MoveIcon
@onready var stop_icon: TextureRect = $StopIcon
@onready var hp_tooltip_area: ColorRect = $HPTooltipArea
@onready var xp_tooltip_area: ColorRect = $XPTooltipArea
@onready var player_lvl_tooltip_area: ColorRect = $PlayerLvlTooltipArea



var skill_tooltip: SkillTooltip
var bars_tooltip: SkillTooltip
var spell_slots: Array[SpellSlot] = []
var passive_slots: Array[SpellSlot] = []
var action_slots: Array[SpellSlot] = []
var max_spell_slots := 4
var hp_bar_style = StyleBoxFlat.new()
var xp_bar_style = StyleBoxFlat.new()
var unit_slots: Array = []
var selected_units: Array = []
var groups_in_selection: Array = []
var unique_orders_in_selection: Array = []
var ctrl_active = false
var current_group_index = -1
var current_page = 1
var total_pages = 1

const SPELL_SLOT_POSITIONS := [
	Vector2(708, 27),
	Vector2(774, 27),
	Vector2(840, 27),
	Vector2(905, 27)
]

const PASSIVE_SLOT_POSITIONS := [
	Vector2(708, -38),
	Vector2(774, -38),
	Vector2(840, -38),
	Vector2(905, -38)
]

const ACTION_SLOT_POSITIONS := [
	Vector2(708, -104),
	Vector2(774, -104),
	Vector2(840, -104),
	Vector2(905, -104)
]

func _ready() -> void:
	print("~HUD READY", self)

	# połączenie z globalnymi sygnałami
	Globals.ui_hp_update_requested.connect(update_hp_bar)
	Globals.ui_exp_update_requested.connect(update_exp_bar)
	Globals.ui_unit_died.connect(_on_unit_died)
	Globals.units_selection_changed.connect(update_units_panel)
	Globals.wave_count_update.connect(wave_count_update)
	Globals.boss_appeared.connect(_on_boss_appeared)
	Globals.boss_health_changed.connect(update_boss_health_bar)

	# zapisanie slotów jednostek
	for child in units_panel.get_children():
		if child is TextureButton:
			unit_slots.append(child)

	# ustawienia pasków zdrowia i xp
	main_damage_bar.max_value = Globals.health
	main_damage_bar.value = 0
	main_damage_bar.visible = true

	xp_gain_bar.max_value = Globals.xp_to_level
	xp_gain_bar.value = Globals.xp_to_level
	xp_gain_bar.visible = true

	player_level.text = "%d" % Globals.level
	hp_value.text = "%d / %d" % [Globals.health, Globals.max_health]
	xp_value.text = "%d / %d" % [Globals.accumulated_xp, Globals.xp_to_level]
	set_process_unhandled_input(true)  
	
	icon_page_1.visible = false
	icon_page_2.visible = false
	icon_page_3.visible = false
	
	spell_slots = [
		scena_spell_slot_1,
		scena_spell_slot_2,
		scena_spell_slot_3,
		scena_spell_slot_4
	]
	
	passive_slots = [
		scena_passive_slot_1,
		scena_passive_slot_2,
		scena_passive_slot_3,
		scena_passive_slot_4
	]	
	
	for i in range(spell_slots.size()):
		var slot := spell_slots[i]
		slot.position = SPELL_SLOT_POSITIONS[i]
		slot.visible = false
		slot.clear()
		slot.hovered.connect(_on_spell_slot_hovered)
		slot.unhovered.connect(_on_spell_slot_unhovered)
	
	for i in range(passive_slots.size()):
		var slot := passive_slots[i]
		slot.position = PASSIVE_SLOT_POSITIONS[i]
		slot.visible = false
		slot.clear()
		slot.hovered.connect(_on_spell_slot_hovered)
		slot.unhovered.connect(_on_spell_slot_unhovered)
	

	Globals.skill_casted.connect(_on_skill_casted)
	Globals.skill_unlocked.connect(update_spell_bar)

	update_spell_bar()

	skill_tooltip = skill_tooltip_scene.instantiate()
	add_child(skill_tooltip)
	skill_tooltip.visible = false
	skill_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_tooltip.position = Vector2(690, -155)
	
	hp_tooltip_area.mouse_entered.connect(_on_hp_bar_hovered)
	hp_tooltip_area.mouse_exited.connect(_on_action_bars_unhovered)

	xp_tooltip_area.mouse_entered.connect(_on_xp_bar_hovered)
	xp_tooltip_area.mouse_exited.connect(_on_action_bars_unhovered)
	
	player_lvl_tooltip_area.mouse_entered.connect(_on_player_lvl_hovered)
	player_lvl_tooltip_area.mouse_exited.connect(_on_action_bars_unhovered)
	

	attack_icon.mouse_entered.connect(_on_action_icon_hovered.bind("Attack"))
	hold_icon.mouse_entered.connect(_on_action_icon_hovered.bind("Hold"))
	move_icon.mouse_entered.connect(_on_action_icon_hovered.bind("Move"))
	stop_icon.mouse_entered.connect(_on_action_icon_hovered.bind("Stop"))
	
	attack_icon.mouse_exited.connect(_on_action_icon_unhovered)
	#attack_icon.mouse_entered.connect(_on_hp_bar_hovered)
	hold_icon.mouse_exited.connect(_on_action_icon_unhovered)
	move_icon.mouse_exited.connect(_on_action_icon_unhovered)
	stop_icon.mouse_exited.connect(_on_action_icon_unhovered)

	bars_tooltip = bars_tooltip_scene.instantiate()
	add_child(bars_tooltip)
	bars_tooltip.visible = false
	bars_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bars_tooltip.position = Vector2(16, -4)
	
	
	
	Achievements.achievement_unlocked.connect(_on_achievement_unlocked)

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

	if event.is_action_pressed("ui_group1"): set_page(1)
	if event.is_action_pressed("ui_group2"): set_page(2)
	if event.is_action_pressed("ui_group3"): set_page(3)

	if event.is_action_released("ui_ctrl"):
		ctrl_active = false
		for unit in selected_units:
			unit.select()
		return
		


func update_hp_bar():
	main_damage_bar.value = Globals.max_health - Globals.health 
	hp_value.text = "%d / %d" % [Globals.health, Globals.max_health]
	var main_health_tween = create_tween()
	main_health_tween.tween_property(main_damage_bar, "value", Globals.max_health - Globals.health, 0.5)
	main_health_tween.set_trans(Tween.TRANS_SINE)
	main_health_tween.set_ease(Tween.EASE_IN_OUT)
	
func update_exp_bar():
	xp_gain_bar.value = Globals.xp_to_level - Globals.accumulated_xp
	xp_value.text = "%d / %d" % [Globals.accumulated_xp, Globals.xp_to_level]
	var xp_tween = create_tween()
	xp_tween.tween_property(xp_gain_bar, "value", Globals.xp_to_level - Globals.accumulated_xp, 0.5)
	xp_tween.set_trans(Tween.TRANS_SINE)
	xp_tween.set_ease(Tween.EASE_IN_OUT)
	player_level.text = "%d" % Globals.level
	if Globals.level > 1:
		player_level.position = Vector2(24,31)

func update_boss_health_bar():
	$BossHealthBar.value = Globals.boss_current_health
	#var main_health_tween = create_tween()
	#main_health_tween.tween_property($BossHealthBar, "value", normalized_boss_health, 0.5)
	#main_health_tween.set_trans(Tween.TRANS_SINE)
	#main_health_tween.set_ease(Tween.EASE_IN_OUT)

func _on_boss_appeared():
	$BossHealthBar.visible = true
	$WaveCounter2.visible = true
	$WaveCounterLabel3.visible = true
	$WaveCounterLabel4.visible = true
	$TextureRect.visible = true
	$BossHealthBar.max_value = Globals.boss_max_health
	$BossHealthBar.value = Globals.boss_max_health
func wave_count_update():
	$WaveCounterLabel2.text = "%d/20" %(Globals.wave_count-1)

func update_units_panel(new_units: Array) -> void:
	selected_units = new_units.filter(func(u): return is_instance_valid(u))
	selected_units.sort_custom(func(a, b): return a.unit_hud_order < b.unit_hud_order)

	# obliczanie stron
	total_pages = int(ceil(float(selected_units.size()) / 12))
	total_pages = clamp(total_pages, 1, 3)
	if current_page > total_pages:
		current_page = total_pages
	elif selected_units.size() == 0:
		total_pages = 0
		icon_page_1.visible = false 
		icon_page_2.visible = false 
		icon_page_3.visible = false 
		
	# zakres jednostek aktualnej strony
	var start = (current_page - 1) * 12
	var end = min(start + 12, selected_units.size())
	var visible_units = []
	if start <= end:
		visible_units = selected_units.slice(start, end)

		
	# reset slotów
	for slot in unit_slots:
		slot.set_meta("unit_ref", null)
		if slot.is_connected("pressed", Callable(self, "_on_unit_slot_pressed")):
			slot.disconnect("pressed", Callable(self, "_on_unit_slot_pressed"))
		var border = slot.get_node_or_null("Border")
		if border:
			border.visible = false
		var icon = slot.get_node_or_null("Icon")
		if icon:
			icon.texture = preload("res://sprites/ui/UnitEmptyIcon.png")
			icon.expand = true
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# wypełnianie slotów widocznymi jednostkami
	for i in range(visible_units.size()):
		var unit = visible_units[i]
		var slot = unit_slots[i]
		var icon = slot.get_node("Icon")
		if unit.icon_texture != "" and ResourceLoader.exists(unit.icon_texture):
			icon.texture = load(unit.icon_texture)
		else:
			icon.texture = preload("res://sprites/ui/EmptyIcon.png")
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		slot.set_meta("unit_ref", unit)
		slot.connect("pressed", Callable(self, "_on_unit_slot_pressed").bind(slot))

		var border = slot.get_node_or_null("Border")
		if border:
			border.visible = true
			border.modulate = Color("dcdcdc") if unit in groups_in_selection else Color(1,1,1,1)

	# aktualizacja unikalnych grup (TAB)
	unique_orders_in_selection.clear()
	for unit in selected_units:
		if not unique_orders_in_selection.has(unit.unit_hud_order):
			unique_orders_in_selection.append(unit.unit_hud_order)
	unique_orders_in_selection.sort()
	current_group_index = -1

	_update_page_icons()

func _on_unit_slot_pressed(slot: TextureButton) -> void:
	if slot.get_meta("unit_ref") == null:
		return

	var clicked_unit = slot.get_meta("unit_ref")
	var units_buffer: Array = []
	for u in selected_units:
		if u.unit_hud_order == clicked_unit.unit_hud_order:
			units_buffer.append(u)

	if groups_in_selection != units_buffer:
		groups_in_selection = units_buffer.duplicate()
		_refresh_visible_borders()
		return

	if unique_orders_in_selection.size() >= 2:
		groups_in_selection = units_buffer.duplicate()
		selection_change()
		selected_units = units_buffer.duplicate()
		update_units_panel(selected_units)
		return

	if groups_in_selection.size() > 1:
		groups_in_selection = [clicked_unit]
		selection_change()
		selected_units = [clicked_unit]
		update_units_panel(selected_units)
		return

	selection_change()

func selection_change() -> void:
	if groups_in_selection.is_empty():
		for unit in selected_units:
			unit.select()
	else:
		for unit in selected_units:
			if unit in groups_in_selection:
				unit.select()
			else:
				unit.deselect()
	_refresh_visible_borders()

func _on_unit_died(unit):
	if unit in selected_units:
		selected_units.erase(unit)
	update_units_panel(selected_units)

func set_page(page: int) -> void:
	current_page = clamp(page, 1, total_pages)
	update_units_panel(selected_units)
	_update_page_icons()

func _update_page_icons():
	var icons = [icon_page_1, icon_page_2, icon_page_3]
	for i in range(3):
		icons[i].visible = true 
		if i + 1 > total_pages:
			icons[i].modulate = Color(0.1, 0.1, 0.1)
		else:
			icons[i].modulate = Color(1,1,1) if current_page == i+1 else Color("777777c3")

func _cycle_unit_group() -> void:
	if unique_orders_in_selection.is_empty():
		icon_page_1.visible = false 
		icon_page_2.visible = false 
		icon_page_3.visible = false 
		return

	current_group_index += 1
	if current_group_index >= unique_orders_in_selection.size():
		current_group_index = -1
		groups_in_selection = selected_units.duplicate()
		_refresh_visible_borders()
		return

	var active_order = unique_orders_in_selection[current_group_index]
	groups_in_selection.clear()
	for u in selected_units:
		if u.unit_hud_order == active_order:
			groups_in_selection.append(u)

	_refresh_visible_borders()

func _refresh_visible_borders() -> void:
	var start = (current_page - 1) * 12
	var end = min(start + 12, selected_units.size())
	for i in range(start, end):
		var slot = unit_slots[i - start]
		var border = slot.get_node_or_null("Border")
		if border:
			var unit = slot.get_meta("unit_ref")
			border.visible = true
			border.modulate = Color("dcdcdc") if unit in groups_in_selection else Color(1.0, 1.0, 1.0, 0.004)

func _on_achievement_unlocked(achievement_key: String) -> void:
	var skill = Achievements.skill_unlock_handler.skill_unlock_dictionary.find_key(achievement_key)
	if skill == null:
		return

	var desc = Achievements.achievement_description_list.get(achievement_key, "")

	var popup = popup_scene.instantiate()
	add_child(popup)
	popup.show_popup(skill, desc)


func update_spell_bar(_skill: Skill = null) -> void:
	# patrzymy na unlocked_skills i filtrujemy tylko ACTIVE
	var active_spells: Array = Skills.unlocked_skills.filter(func(s):
		return s.use_tags.has(Tags.UseTag.ACTIVE)
	)
	# tu tylko PASIVE
	var passive_spells: Array = Skills.unlocked_skills.filter(func(s):
		return !s.use_tags.has(Tags.UseTag.ACTIVE) and !s.use_tags.has(Tags.UseTag.SUMMON)
	)
	

	print("*Active spells:", active_spells.map(func(s): return s.skill_name))
	print("*Passive spells:", passive_spells.map(func(s): return s.skill_name))

	for i in range(spell_slots.size()):
		var slot := spell_slots[i]

		if i < active_spells.size():
			slot.visible = true
			slot.set_skill(active_spells[i], i+1)
		else:
			slot.visible = false
			slot.clear()


	for i in range(passive_slots.size()):
		var slot := passive_slots[i]

		if i < passive_spells.size():
			slot.visible = true
			slot.set_skill(passive_spells[i])
		else:
			slot.visible = false
			slot.clear()


func _on_skill_casted(skill: Skill, cooldown: float):
	for slot in spell_slots:
		if slot.skill == skill:
			slot.start_cooldown(cooldown)



func _on_spell_slot_hovered(skill: Skill, order_number) -> void:
	skill_tooltip.show_spell_text(skill, order_number)

func _on_spell_slot_unhovered() -> void:
	skill_tooltip.hide_tooltip()


func _on_action_icon_hovered(icon_name: String) -> void:
	skill_tooltip.show_text(icon_name)


func _on_action_icon_unhovered() -> void:
	skill_tooltip.hide_tooltip()
	
func _on_action_bars_unhovered() -> void:
	bars_tooltip.hide_tooltip()
	
func _on_hp_bar_hovered() -> void:
	print("+Mysz weszła na HP Bar!")
	if bars_tooltip:
		bars_tooltip.show_bar_text("HPBar")

func _on_xp_bar_hovered() -> void:
	if bars_tooltip:
		bars_tooltip.show_bar_text("XPBar")
	
func _on_player_lvl_hovered() -> void:
	if bars_tooltip:
		bars_tooltip.show_player_lvl_text()
