extends Node3D

var base_position: Vector3

func _ready() -> void:
	base_position = position
	InputManager.power_press_executed.connect(trigger_heavy_shake)

func trigger_heavy_shake() -> void:
	var tween = create_tween()
	# Quick 3D camera jolt in random directions, then snap back to center
	for i in range(4):
		var random_offset = Vector3(
			randf_range(-0.15, 0.15),
			randf_range(-0.15, 0.15),
			0.0
		)
		tween.tween_property(self, "position", base_position + random_offset, 0.04)
	tween.tween_property(self, "position", base_position, 0.05)
