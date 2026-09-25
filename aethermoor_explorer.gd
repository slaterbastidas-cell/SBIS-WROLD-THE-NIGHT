extends Camera3D

@export var move_speed := 220.0
@export var boost_multiplier := 4.0
@export var look_sensitivity := 0.08
# yaw 0 = mira hacia -Z (hacia el origen / isla)
var _yaw := 0.0
var _pitch := -18.0
var _mouse_look := false

func _ready() -> void:
	# Vista elevada mirando la isla centrada en el origen
	position = Vector3(0.0, 9000.0, 22000.0)
	rotation_degrees = Vector3(_pitch, _yaw, 0.0)
	current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_mouse_look = event.pressed
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if _mouse_look else Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion and _mouse_look:
		_yaw -= event.relative.x * look_sensitivity
		_pitch = clamp(_pitch - event.relative.y * look_sensitivity, -89.0, 89.0)
		rotation_degrees = Vector3(_pitch, _yaw, 0.0)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_mouse_look = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	var local_direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_A):
		local_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		local_direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		local_direction.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		local_direction.z += 1.0
	if Input.is_key_pressed(KEY_Q):
		local_direction.y -= 1.0
	if Input.is_key_pressed(KEY_E):
		local_direction.y += 1.0

	if local_direction.length_squared() > 0.0:
		local_direction = local_direction.normalized()
		var speed := move_speed * (boost_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		global_position += global_transform.basis * local_direction * speed * delta

	WorldManager.update_player_position(global_position)
