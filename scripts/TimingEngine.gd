extends Node
class_name TimingEngine

# Timing windows defined in milliseconds
@export var target_time_ms: int = 1000 # The exact moment the shrinking ring perfectly aligns (1 second)
@export var perfect_tolerance: int = 150 # +/- 150ms window for a Perfect hit
@export var good_tolerance: int = 350    # +/- 350ms window for a Good hit

var chew_start_time: int = 0
var is_chewing: bool = false

func start_chew_timer() -> void:
	chew_start_time = Time.get_ticks_msec()
	is_chewing = true

func evaluate_swallow() -> String:
	if not is_chewing:
		return "IGNORED"
		
	is_chewing = false
	
	# Calculate exactly how long the food was in the chew buffer
	var elapsed_time = Time.get_ticks_msec() - chew_start_time
	
	# Calculate the absolute difference from our perfect target
	var time_difference = abs(elapsed_time - target_time_ms)
	
	if time_difference <= perfect_tolerance:
		return "PERFECT"
	elif time_difference <= good_tolerance:
		return "GOOD"
	else:
		return "SLOPPY"
