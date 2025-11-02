extends Control

@onready var main_health_bar: ProgressBar = $HealthBar 
@onready var main_damage_bar: ProgressBar = $DamageBar
@onready var xp_bar: ProgressBar = $XpBar
@onready var xp_gain_bar: ProgressBar = $XpGainBar
var hp_bar_style = StyleBoxFlat.new()
var xp_bar_style = StyleBoxFlat.new()

func _ready() -> void:
	Globals.stats_changed.connect(update_bars)

	main_health_bar.max_value = Globals.health
	main_health_bar.value = Globals.health
	main_health_bar.visible = false
	main_damage_bar.max_value = Globals.health
	main_damage_bar.value = Globals.health
	main_damage_bar.visible = false
	
	hp_bar_style.bg_color = Color("ff45edff")
	hp_bar_style.border_width_left = 4
	hp_bar_style.border_width_top = 4
	hp_bar_style.border_width_bottom = 4
	hp_bar_style.border_width_right = 5
	hp_bar_style.border_color = Color(0.0, 0.0, 0.0, 1.0)
	main_health_bar.add_theme_stylebox_override("fill", hp_bar_style)
	
	main_health_bar.visible = true
	main_damage_bar.visible = true
	
	
	xp_bar.max_value = Globals.max_xp
	xp_bar.value = Globals.xp
	xp_gain_bar.max_value = Globals.max_xp
	xp_gain_bar.value = Globals.xp

	xp_bar_style.bg_color = Color("e8d500ff")
	xp_bar_style.border_width_left = 2
	xp_bar_style.border_width_top = 2
	xp_bar_style.border_width_bottom = 2
	xp_bar_style.border_color = Color(0.0, 0.0, 0.0, 1.0)
	xp_bar.add_theme_stylebox_override("fill", xp_bar_style)
	xp_gain_bar.add_theme_stylebox_override("fill", xp_bar_style)
	
	xp_bar.visible = true
	xp_gain_bar.visible = true
	
	
func update_bars():
	print(Globals.health)
	main_health_bar.value = Globals.health
	
	var main_health_tween = create_tween()
	var xp_tween = create_tween()
	main_health_tween.tween_property(main_damage_bar, "value", Globals.health, 0.5) 
	main_health_tween.set_trans(Tween.TRANS_SINE)
	main_health_tween.set_ease(Tween.EASE_OUT)
	
	xp_tween.tween_property(xp_gain_bar, "value", Globals.xp, 0.8) 
	xp_tween.set_trans(Tween.TRANS_SINE)
	xp_tween.set_ease(Tween.EASE_OUT)
