extends CanvasLayer

@export var player_stats: PlayerStats

func _ready() -> void:
	if player_stats:
		player_stats.capacity_changed.connect(update_stomach_bar)
		player_stats.choke_changed.connect(update_choke_gauge)
		player_stats.hydration_changed.connect(update_hydration_meter)

func update_stomach_bar(current: float, max_val: float) -> void:
	$StomachBar.max_value = max_val
	var tween = create_tween()
	tween.tween_property($StomachBar, "value", current, 0.15).set_trans(Tween.TRANS_SINE)

func update_choke_gauge(current: float, max_val: float) -> void:
	$ChokeGauge.max_value = max_val
	var tween = create_tween()
	tween.tween_property($ChokeGauge, "value", current, 0.1).set_trans(Tween.TRANS_SINE)

func update_hydration_meter(current: float, max_val: float) -> void:
	$HydrationMeter.max_value = max_val
	var tween = create_tween()
	tween.tween_property($HydrationMeter, "value", current, 0.15).set_trans(Tween.TRANS_SINE)
