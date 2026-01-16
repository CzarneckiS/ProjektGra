extends Node2D
class_name IceblockSpell

var skill_resource: Iceblock
const diagonal_threshold = 0.6
var lifespan: Timer = Timer.new()
var actual_orientation: String = ""
@onready var opacity_area: Area2D = $pivotpoint/opacity_area
@onready var damage_area: Area2D = $pivotpoint/damage_area
@onready var knockback_area: Area2D = $pivotpoint/knockback_area
@onready var diagonal_damage_area: Area2D = $pivotpoint/diagonal_damage_area
@onready var diagonal_knockback_area: Area2D = $pivotpoint/diagonal_knockback_area
@onready var iceblock_animation: AnimationPlayer = $pivotpoint/iceblock_animation
@onready var navigation_region_2d: NavigationRegion2D = get_node("../NavigationRegion2D")
@onready var pivotpoint: Node2D = $pivotpoint
@onready var iceblock_projectile_block_area: Area2D = $pivotpoint/iceblock_projectile_block_area
@onready var iceblock_transformation_area: Area2D = $pivotpoint/iceblock_transformation_area
	
func initialize(spawn_position: Vector2, skill_res: Iceblock):
	skill_resource = skill_res
	global_position = spawn_position
	
	add_child(lifespan)
	lifespan.one_shot = true
	lifespan.autostart = false
	lifespan.wait_time = 4.0
func _ready():
	lifespan.call_deferred("start")
	_get_iceblock_animation()
	
	opacity_area.body_entered.connect(update_opacity_update)
	opacity_area.body_exited.connect(update_opacity_update)
	
	damage_area.body_entered.connect(_on_damage_area_entered)
	knockback_area.body_entered.connect(_on_knockback_area_entered)
	diagonal_damage_area.body_entered.connect(_on_damage_area_entered)
	diagonal_knockback_area.body_entered.connect(_on_knockback_area_entered)
	iceblock_projectile_block_area.area_entered.connect(_on_iceblock_projectile_block_entered)
	
	lifespan.timeout.connect(_on_lifespan_timeout)
	
	navigation_region_2d.call_deferred("bake_navigation_polygon")
	
	$pivotpoint/iceblock_sfx.play()

func _on_lifespan_timeout():
	call_deferred("queue_free")
	
func _on_damage_area_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		body.hit(skill_resource.effect_damage.base_damage*skill_resource.effect_damage.damage_multiplier, self)
		
func _on_knockback_area_entered(body: UnitParent):
	if !body.is_in_group("Allied"):
		skill_resource.effect_knockback.apply_push(global_position, body)

func get_screen_region() -> String:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	var half_screen_size = screen_size / 2.0
	var region: String = ""
	
	if mouse_pos.x < half_screen_size.x:
		region += "Left"
	else:
		region += "Right"
	if mouse_pos.y < half_screen_size.y:
		region += "Up"
	else:
		region += "Down"
	
	var offset = mouse_pos - half_screen_size
	var abs_x = abs(offset.x)
	var abs_y = abs(offset.y)
	
	if abs_x > abs_y * (1.0 + diagonal_threshold):
		region = region.replace("Up", "").replace("Down", "")
	elif abs_y > abs_x * (1.0 + diagonal_threshold):
		region = region.replace("Right", "").replace("Left", "")
	
	actual_orientation = region
	
	return region
	
func _get_iceblock_animation():
	match get_screen_region():
		"Up":
			iceblock_animation.play("ice_wall_front")
		"Down":
			iceblock_animation.play("ice_wall_front")
		"Left":
			iceblock_animation.play("ice_wall_side")
		"Right":
			iceblock_animation.play("ice_wall_side")
		"RightUp":
			pivotpoint.scale.x = -1
			iceblock_animation.play("ice_wall_diagonal")
		"LeftUp":
			iceblock_animation.play("ice_wall_diagonal")
		"RightDown":
			iceblock_animation.play("ice_wall_diagonal")
		"LeftDown":
			pivotpoint.scale.x = -1
			iceblock_animation.play("ice_wall_diagonal")

func update_opacity_update(_body):
	var opacity_tween = create_tween()
	if broken:
		opacity_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.05)
		return
	if opacity_area.get_overlapping_bodies().is_empty():
		opacity_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15) 
	else:
		opacity_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.15)
	opacity_tween.set_trans(Tween.TRANS_SINE)
	opacity_tween.set_ease(Tween.EASE_OUT)

func _on_iceblock_projectile_block_entered(projectile):
	if projectile.is_in_group("EnemyProjectile"):
		projectile.call_deferred("queue_free")
	else:
		return

var broken: bool = false

func change_sprite_to_broken():
	broken = true
	var opacity_tween = create_tween()
	opacity_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
	opacity_tween.set_trans(Tween.TRANS_SINE)
	opacity_tween.set_ease(Tween.EASE_OUT)
	$pivotpoint/iceblock_sprites.visible = false
	match actual_orientation:
		"Up":
			$pivotpoint/broken_front.visible = true
		"Down":
			$pivotpoint/broken_front.visible = true
		"Left":
			$pivotpoint/broken_side.visible = true
		"Right":
			$pivotpoint/broken_side.visible = true
		"RightUp":
			pivotpoint.scale.x = -1
			$pivotpoint/broken_diagonal.visible = true
		"LeftUp":
			$pivotpoint/broken_diagonal.visible = true
		"RightDown":
			$pivotpoint/broken_diagonal.visible = true
		"LeftDown":
			pivotpoint.scale.x = -1
			$pivotpoint/broken_diagonal.visible = true
