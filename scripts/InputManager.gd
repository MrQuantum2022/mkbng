extends Node

# Signals to communicate with the Player FSM
signal combo_registered(combo_string: String)
signal power_press_executed()
signal input_dropped()

@export var buffer_timeout_ms: int = 600 # Max time between inputs before combo resets
@export var simultaneous_tolerance_ms: int = 50 # 3-frame window (at 60fps) for Y+A

var input_buffer: Array[Dictionary] = []
var last_input_time: int = 0

func _process(_delta: float) -> void:
	_check_buffer_timeout()

func _input(event: InputEvent) -> void:
	# Only register actual button presses, not releases
	if not event.is_pressed() or event.is_echo():
		return
		
	var current_time = Time.get_ticks_msec()
	
	if event.is_action("bite_quick"):
		_add_to_buffer("X", current_time)
	elif event.is_action("bite_heavy"):
		_add_to_buffer("Y", current_time)
	elif event.is_action("sip"):
		_add_to_buffer("B", current_time)
	elif event.is_action("swallow"):
		_add_to_buffer("A", current_time)
		_evaluate_buffer()

func _add_to_buffer(input_char: String, timestamp: int) -> void:
	# Check for simultaneous Y+A (Power Press)
	if input_char == "A" and input_buffer.size() > 0:
		var last_input = input_buffer[-1]
		if last_input["key"] == "Y" and (timestamp - last_input["time"]) <= simultaneous_tolerance_ms:
			power_press_executed.emit()
			input_buffer.clear()
			return
			
	input_buffer.append({
		"key": input_char,
		"time": timestamp
	})
	last_input_time = timestamp

func _check_buffer_timeout() -> void:
	if input_buffer.is_empty(): 
		return
		
	var current_time = Time.get_ticks_msec()
	# If the time since the last button press exceeds the window, drop the combo
	if current_time - last_input_time > buffer_timeout_ms:
		input_dropped.emit()
		input_buffer.clear()

func _evaluate_buffer() -> void:
	# The 'A' button acts as the combo terminator. Read the string and send it to the FSM.
	var final_combo_string = ""
	for item in input_buffer:
		final_combo_string += item["key"]
		
	combo_registered.emit(final_combo_string)
	input_buffer.clear()
