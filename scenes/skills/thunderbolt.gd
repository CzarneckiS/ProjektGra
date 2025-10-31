extends Area2D

var skill_resource: Thunderbolt
var aoe_scale: Vector2

func initialize(spawn_position: Vector2, skill_res: Thunderbolt):
	skill_resource = skill_res
	
	global_position = spawn_position
	
		
func _ready():
	$thunderbolt_animation.play("default")
	$thunderbolt_animation.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	
func _on_animation_finished():
	call_deferred("queue_free")
	
func _physics_process(_delta: float) -> void:
	if skill_resource == null:
		queue_free()
		return

func _on_body_entered(body: UnitParent):
	if body.is_in_group("Unit"):
		body.hit(10) #skill_resource.skill_effect_data.base_damage
