extends Resource

@export var visual_effect: PackedScene

func use(unit: CharacterBody2D, target: CharacterBody2D) -> void:
	var visual_effect_node = visual_effect.instantiate()
	unit.get_parent().get_tree().root.add_child(visual_effect_node)
	visual_effect_node.initialize(unit, target)
