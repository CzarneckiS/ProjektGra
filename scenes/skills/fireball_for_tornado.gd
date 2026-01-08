extends Area2D
class_name FireballTornadoSpell

var skill_resource: Fireball

var user
var local_shift
var angle = 0.0
var hit: bool = false

func initialize(start_pos, _target_pos: Vector2, skill_res: Fireball, shift: float):
	skill_resource = skill_res
	local_shift = shift
	user = start_pos
	global_position = start_pos.global_position
	
func _ready():
	$fireball_animation.play("on_creation")
	body_entered.connect(_on_body_entered)
	$fireball_animation.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
	
	angle += delta * 2.0
	if user != null:		
		global_position = user.global_position + skill_resource.offset.rotated(angle + local_shift)
		global_rotation = angle + local_shift + PI
	else:
		call_deferred("queue_free")
	
func _on_body_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		body.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
		skill_resource.effect_knockback.apply_push(global_position, body)

func _on_animation_finished():
	if $fireball_animation.animation == "on_creation":
		$fireball_animation.play("default")
