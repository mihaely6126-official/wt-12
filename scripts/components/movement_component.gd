extends Component
class_name MovementComponent

@export var walk_speed := 4.0
@export var sprint_speed := 7.0
@export var crouch_speed := 2.0
@export var jump_velocity := 6.0
@export var acceleration := 10.0
@export var air_control := 0.3

var is_crouching := false
var is_sprinting := false
var body: CharacterBody3D
var stats: StatsComponent
var camera_mount: Node3D
var visuals: Node3D

func _ready():
	body = owner as CharacterBody3D
	stats = body.get_node("Components/StatsComponent")
	camera_mount = body.get_node("CameraMount")
	visuals = body.get_node("Visuals")

func _physics_process(delta):
	if not body: return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (camera_mount.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Скорость
	var target_speed = walk_speed
	if is_sprinting and stats and stats.current_stamina > 0:
		target_speed = sprint_speed
		stats.consume_stamina(0.5 * delta)
	elif is_crouching:
		target_speed = crouch_speed
	
	# Поворот персонажа по направлению взгляда
	if direction.length() > 0.1:
		visuals.look_at(body.global_position + direction, Vector3.UP)
	
	# Горизонтальное движение
	var target_vel = direction * target_speed
	if body.is_on_floor():
		body.velocity.x = move_toward(body.velocity.x, target_vel.x, acceleration * delta)
		body.velocity.z = move_toward(body.velocity.z, target_vel.z, acceleration * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, target_vel.x, acceleration * air_control * delta)
		body.velocity.z = move_toward(body.velocity.z, target_vel.z, acceleration * air_control * delta)
	
	if not body.is_on_floor():
		body.velocity.y -= 9.8 * delta
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		body.velocity.y = jump_velocity
	
	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and body.is_on_floor() and not is_crouching
	
	body.move_and_slide()
