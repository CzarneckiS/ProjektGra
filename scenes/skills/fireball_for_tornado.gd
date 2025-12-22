extends Area2D
class_name FireballTornadoSpell

var skill_resource: Fireball

var start_position
var offset = Vector2(200,0)
var angle = 0.0
var hit: bool = false

func initialize(start_pos, _target_pos: Vector2, skill_res: Fireball):
	skill_resource = skill_res
	
	start_position = start_pos
	global_position = start_pos
	
func _ready():
	$fireball_animation.play("default")
	body_entered.connect(_on_body_entered)
	$fireball_animation.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
		
	angle += delta * 2.0
	global_position = start_position + offset.rotated(angle)
	
func _on_body_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		hit = true
		$fireball_animation.play("splash")
		$fireball_animation.scale = Vector2(1.5, 1.5)
		body.hit(skill_resource.skill_effect_data.base_damage*skill_resource.skill_effect_data.damage_multiplier, self)
		skill_resource.effect_knockback.apply_push(global_position, body)

func _on_animation_finished():
	call_deferred("queue_free")
