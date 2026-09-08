class_name CameraController
extends Component

@export var mouse_sensitivity := 0.002
@export var vertical_limit_min := -80.0
@export var vertical_limit_max := 80.0
@export var shoulder_offset_right := Vector3(0.6, 0.15, 0)  # смещение при правом плече
@export var aim_distance := 50.0  # дальность точки прицеливания

var camera_mount: Node3D
var spring_arm: SpringArm3D
var visuals: Node3D
var current_pitch := 0.0
var current_shoulder := 1  # 1 – правое, -1 – левое

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var body = owner as CharacterBody3D
	if not body:
		push_error("CameraController: owner is not CharacterBody3D")
		return

	camera_mount = body.get_node("CameraMount")
	spring_arm = body.get_node("CameraMount/SpringArm3D")
	visuals = body.get_node("Visuals")

	if not camera_mount or not spring_arm or not visuals:
		push_error("CameraController: missing nodes")
		return

	# Устанавливаем начальное смещение камеры
	_apply_shoulder_offset()

func _input(event):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		var yaw_delta = -event.relative.x * mouse_sensitivity
		camera_mount.rotate_y(yaw_delta)
		visuals.rotate_y(yaw_delta)

		var pitch_delta = -event.relative.y * mouse_sensitivity
		current_pitch = clamp(current_pitch + pitch_delta, deg_to_rad(vertical_limit_min), deg_to_rad(vertical_limit_max))
		spring_arm.rotation.x = current_pitch

	if event.is_action_pressed("switch_shoulder"):
		current_shoulder *= -1
		_apply_shoulder_offset()

func _apply_shoulder_offset():
	spring_arm.position = shoulder_offset_right * current_shoulder
	spring_arm.spring_length = 0.0
	spring_arm.position = Vector3(shoulder_offset_right.x * current_shoulder, shoulder_offset_right.y, shoulder_offset_right.z)

func release_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
