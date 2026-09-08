extends Component
class_name StatsComponent

signal health_changed(current, max)
signal stamina_changed(current, max)
signal died

@export var max_health := 16.0
@export var max_stamina := 16.0
@export var stamina_regen_rate := 1.0   # ед/сек
@export var stamina_regen_delay := 1.0  # сек после расхода

var current_health: float
var current_stamina: float
var stamina_regen_blocked_until := 0.0

func _ready():
	current_health = max_health
	current_stamina = max_stamina

func _process(delta):
	# Регенерация стамины
	var now = Time.get_ticks_msec() / 1000.0
	if now >= stamina_regen_blocked_until and current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

func take_damage(amount: float):
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_regen_blocked_until = Time.get_ticks_msec() / 1000.0 + stamina_regen_delay
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

#func apply_buff(buff: BuffData):
	# будет реализовано позже
#	pass
