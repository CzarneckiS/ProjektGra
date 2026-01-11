extends Area2D
class_name FireballSpell

var skill_resource: Fireball

var start_position: Vector2
var end_position: Vector2
var direction: Vector2
var hit: bool = false

func initialize(start_pos, target_pos: Vector2, skill_res: Fireball, _shift):
	skill_resource = skill_res
	
	start_position = start_pos.global_position
	global_position = start_pos.global_position
	end_position = target_pos
	
	direction = (end_position - start_position).normalized()
	look_at(target_pos)
	
func _ready():
	body_entered.connect(_on_body_entered)
	$fireball_animation.animation_finished.connect(_on_animation_finished)
	$fireball_animation.play("on_creation")
	$fireball_sfx.play()
	$fireball_sfx.finished.connect(_on_sfx_finished)
	
func _physics_process(delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return
		
	if !hit:
		global_position += direction * skill_resource.speed * delta
	
	var current_distance: float = start_position.distance_to(global_position)
	if current_distance >= skill_resource.max_range:
		hide()
	
func _on_body_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		hit = true
		$fireball_animation.play("splash")
		$fireball_animation.scale = Vector2(1.5, 1.5)
		body.hit(skill_resource.skill_effect_data.base_damage**skill_resource.skill_effect_data.damage_multiplier, self)
		skill_resource.effect_knockback.apply_push(global_position, body)

func _on_animation_finished():
	if $fireball_animation.animation == "on_creation":
		$fireball_animation.play("default")
	if $fireball_animation.animation == "splash":
		call_deferred("hide")

func _on_sfx_finished():
	call_deferred("queue_free")
