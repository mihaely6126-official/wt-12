extends Component
class_name HealthComponent

@export var limb_multipliers := {
	"head": 2.0,
	"torso": 1.0,
	"legs": 0.7
}
var stats: StatsComponent

func _ready():
	stats = get_parent().get_node("StatsComponent")  # или задать вручную

func apply_damage(amount: float, limb: String = "torso") -> float:
	var mult = limb_multipliers.get(limb, 1.0)
	var final_damage = amount * mult
	stats.take_damage(final_damage)
	return final_damage

func apply_heal(amount: float):
	stats.heal(amount)
