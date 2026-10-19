extends Node
class_name PlayerStats

# Signals for the UI to listen to
signal capacity_changed(current: float, max_val: float)
signal choke_changed(current: float, max_val: float)
signal hydration_changed(current: float, max_val: float)
signal nausea_changed(current: float, max_val: float)

# Signals for the FSM to listen to
signal food_coma_triggered()
signal choke_stun_triggered()
signal queasy_stun_triggered()

# Max stat limits (Exported so you can tweak them in the Godot Inspector per character)
@export var max_capacity: float = 100.0
@export var max_choke: float = 100.0
@export var max_hydration: float = 100.0
@export var max_nausea: float = 100.0

# Current stat values
var current_capacity: float = 0.0
var current_choke: float = 0.0
var current_hydration: float = 100.0 # Starts full
var current_nausea: float = 0.0

func _ready() -> void:
	# Initialize UI on boot
	_emit_all_stats()

# --- MODIFIER FUNCTIONS ---
# The FSM will call these functions based on inputs and dish data

func process_swallow(base_volume: float, choke_penalty: float, nausea_penalty: float, hardness_multiplier: float = 1.0) -> void:
	# Calculate the actual volume based on modifiers (like the Y+A Power Press)
	var final_volume = base_volume * hardness_multiplier
	
	current_capacity += final_volume
	current_choke += choke_penalty
	current_nausea += nausea_penalty
	
	_clamp_and_check_thresholds()
	
	capacity_changed.emit(current_capacity, max_capacity)
	choke_changed.emit(current_choke, max_choke)
	nausea_changed.emit(current_nausea, max_nausea)

func process_sip(hydration_restore: float, choke_relief: float) -> void:
	# Sipping reduces choke and restores hydration, but takes up stomach capacity
	current_hydration += hydration_restore
	current_choke -= choke_relief
	current_capacity += (hydration_restore * 0.2) # Water fills you up a little bit!
	
	_clamp_and_check_thresholds()
	
	hydration_changed.emit(current_hydration, max_hydration)
	choke_changed.emit(current_choke, max_choke)
	capacity_changed.emit(current_capacity, max_capacity)

func drain_hydration(amount: float) -> void:
	# Called continually by the FSM if the player is in a "Heat State" (Spice > 70%)
	current_hydration -= amount
	_clamp_and_check_thresholds()
	hydration_changed.emit(current_hydration, max_hydration)

# --- INTERNAL LOGIC ---

func _clamp_and_check_thresholds() -> void:
	# Keep stats within 0 and Max boundaries
	current_capacity = clamp(current_capacity, 0.0, max_capacity)
	current_choke = clamp(current_choke, 0.0, max_choke)
	current_hydration = clamp(current_hydration, 0.0, max_hydration)
	current_nausea = clamp(current_nausea, 0.0, max_nausea)
	
	# Broadcast Stun / Fail states to the FSM
	if current_capacity >= max_capacity:
		food_coma_triggered.emit()
		
	if current_choke >= max_choke:
		choke_stun_triggered.emit()
		current_choke = 0 # Reset after triggering the stun
		
	if current_nausea >= max_nausea:
		queasy_stun_triggered.emit()
		current_nausea = 0 # Reset after triggering the stun

func _emit_all_stats() -> void:
	capacity_changed.emit(current_capacity, max_capacity)
	choke_changed.emit(current_choke, max_choke)
	hydration_changed.emit(current_hydration, max_hydration)
	nausea_changed.emit(current_nausea, max_nausea)
