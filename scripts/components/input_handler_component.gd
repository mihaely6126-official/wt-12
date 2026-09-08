extends Component
class_name InputHandlerComponent


signal light_attack
signal heavy_attack(multiplier: float)
signal block_started
signal block_stopped

@export var max_charge_time := 3.0
@export var max_multiplier := 2.0
@export var charge_curve_power := 0.5

var is_charging := false
var charge_start_time := 0.0
var current_multiplier := 1.0

func _input(event):
	# Игнорируем ввод, если мышь не захвачена (например, открыт UI)
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				charge_start_time = Time.get_ticks_msec() / 1000.0
				is_charging = true
			else:
				if is_charging:
					var elapsed = Time.get_ticks_msec() / 1000.0 - charge_start_time
					if elapsed < 0.1:
						light_attack.emit()
					else:
						current_multiplier = calculate_multiplier(elapsed)
						heavy_attack.emit(current_multiplier)
					is_charging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				block_started.emit()
			else:
				block_stopped.emit()

func calculate_multiplier(charge_time: float) -> float:
	var t = min(charge_time, max_charge_time)
	var ratio = t / max_charge_time
	var curved = pow(ratio, charge_curve_power)
	return 1.0 + curved * (max_multiplier - 1.0)
