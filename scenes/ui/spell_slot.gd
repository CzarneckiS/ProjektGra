extends Control
class_name SpellSlot

@onready var icon: TextureRect = $Icon
@onready var cooldown_mask: ColorRect = $CooldownMask
@onready var cooldown_label: Label = $CooldownLabel

var skill: Skill
var cooldown_time := 0.0
var remaining := 0.0

signal hovered(skill: Skill)
signal unhovered()

func set_skill(_skill: Skill):
	skill = _skill
	if _skill.icon != null:
		icon.texture = skill.icon

		icon.scale = Vector2.ONE
		icon.scale = Vector2(0.13, 0.13)
		icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)


	#reset_cooldown()

	
func start_cooldown(time: float):
	cooldown_time = time
	remaining = time
	cooldown_mask.visible = true
	set_process(true)

func reset_cooldown():
	remaining = 0
	cooldown_mask.visible = false
	cooldown_label.text = ""
	set_process(false)

func _process(delta):
	if remaining <= 0:
		reset_cooldown()
		return

	remaining -= delta
	cooldown_label.text = str(snapped(remaining, 0.1))


func clear():
	skill = null
	icon.texture = null


func _on_mouse_entered():
	if skill != null:
		hovered.emit(skill)

func _on_mouse_exited():
	unhovered.emit()
