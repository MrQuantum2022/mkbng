extends Sprite3D

@export var player_fsm: PlayerFSM

var active_tween: Tween
var base_scale: Vector3

func _ready() -> void:
	base_scale = scale
	if player_fsm:
		player_fsm.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state: int) -> void:
	# Stop any running animation and reset visuals
	if active_tween and active_tween.is_running():
		active_tween.kill()
	scale = base_scale
	modulate = Color.WHITE
	
	match new_state:
		PlayerFSM.State.IDLE:
			pass # Neutral state
			
		PlayerFSM.State.CHEWING:
			_play_chew_effect()
			
		PlayerFSM.State.CHOKE_STUN:
			_play_choke_effect()
			
		PlayerFSM.State.QUEASY_STUN:
			modulate = Color(0.4, 1.0, 0.4) # Sickly green tint

func _play_chew_effect() -> void:
	# Rapid squash-and-stretch loop to simulate aggressive chewing on a single PNG
	active_tween = create_tween().set_loops()
	active_tween.tween_property(self, "scale", base_scale * Vector3(1.12, 0.88, 1.0), 0.1)
	active_tween.tween_property(self, "scale", base_scale * Vector3(0.92, 1.08, 1.0), 0.1)

func _play_choke_effect() -> void:
	# Flash red and jolt scale for choking stun
	modulate = Color(1.0, 0.3, 0.3)
	active_tween = create_tween().set_loops(6)
	active_tween.tween_property(self, "scale", base_scale * 1.15, 0.05)
	active_tween.tween_property(self, "scale", base_scale * 0.95, 0.05)
