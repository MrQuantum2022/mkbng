extends Node
class_name PlayerFSM

signal state_changed(new_state: State)
enum State { IDLE, CHEWING, CHOKE_STUN, QUEASY_STUN, ZONE }
var current_state: State = State.IDLE

# --- NEW: Drag and drop a DishData resource here in the Inspector ---
@export var current_dish: DishData 
@export var player_stats: PlayerStats # Link the math engine here
@export var timing_engine: TimingEngine

func _ready() -> void:
	InputManager.combo_registered.connect(_on_combo_registered)
	InputManager.power_press_executed.connect(_on_power_press)
	InputManager.input_dropped.connect(_on_input_dropped)
	
	# Optional: Safety check so the game doesn't crash if you forget to equip a dish
	if current_dish == null:
		push_error("No DishData equipped on FSM!")

func _process(delta: float) -> void:
	if current_state == State.IDLE and InputManager.input_buffer.size() > 0:
		_evaluate_initial_bite(InputManager.input_buffer[0]["key"])

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	state_changed.emit(current_state)
	match current_state:
		State.IDLE:
			print("State: IDLE. Ready.")
		State.CHEWING:
			print("State: CHEWING. Timing ring started!")
			timing_engine.start_chew_timer()
		State.CHOKE_STUN:
			print("State: CHOKING! Input locked.")
			InputManager.input_buffer.clear()
		State.QUEASY_STUN:
			print("State: QUEASY. Controls inverted.")

func _evaluate_initial_bite(first_input: String) -> void:
	# --- UPDATED: Now safely checking the Resource array ---
	if current_dish and first_input in current_dish.restricted_buttons:
		print("FATAL BITE: Triggered dish constraint penalty!")
		change_state(State.CHOKE_STUN)
		return
		
	change_state(State.CHEWING)

func _on_combo_registered(combo_string: String) -> void:
	if current_state != State.CHEWING:
		return
	
	var accuracy = timing_engine.evaluate_swallow()
	print("Combo: ", combo_string, " | Accuracy: ", accuracy)
	
	# Scale the penalties based on player precision
	var choke_multiplier = 1.0
	if accuracy == "SLOPPY":
		choke_multiplier = 2.0 # Punish a bad timing window
	elif accuracy == "PERFECT":
		choke_multiplier = 0.5 # Reward frame-perfect execution
		
	if player_stats and current_dish:
		player_stats.process_swallow(
			current_dish.base_volume_fill,
			current_dish.choke_penalty * choke_multiplier,
			current_dish.nausea_penalty
		)
	
	change_state(State.IDLE)


func _on_power_press() -> void:
	if current_state in [State.CHOKE_STUN, State.QUEASY_STUN]:
		return 
		
	print("POWER PRESS EXECUTED (Y+A)")
	
	# --- NEW: Applying the Hardness Factor for the Power Press ---
	if player_stats and current_dish:
		player_stats.process_swallow(
			current_dish.base_volume_fill, 
			current_dish.choke_penalty * 2.0, # Massive choke spike for bypassing chew
			current_dish.nausea_penalty,
			current_dish.hardness_factor
		)
		
	change_state(State.IDLE)

func _on_input_dropped() -> void:
	if current_state == State.CHEWING:
		print("Hesitation penalty: Sloppy Swallow!")
		change_state(State.IDLE)
