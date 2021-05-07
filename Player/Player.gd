extends KinematicBody

export var speed := 5.0
export var acceleration := 10.0
export var air_acceleration := 5.0
export var gravity := .98
export var max_terminal_velocity := 54.0
export var jump_power := 20.0

export(float, 0.1, 1) var mouse_sensitivity := .3
export(float, -90, 0) var min_pitch := -50.0
export(float, 0, 90) var max_pitch := 30.0
export(NodePath) onready var animation_tree = get_node(animation_tree)

var velocity :Vector3
var y_velocity :float

onready var camera_root = $CameraRoot
onready var camera = $CameraRoot/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		handle_camera(event)
	

func _physics_process(delta):
	handle_movement(delta)

func handle_camera(event) -> void:
	rotation_degrees.y -= event.relative.x * mouse_sensitivity
	camera_root.rotation_degrees.x -= event.relative.y * mouse_sensitivity
	camera_root.rotation_degrees.x = clamp(camera_root.rotation_degrees.x, 
			min_pitch, max_pitch)


func handle_movement(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
		
		
	elif Input.is_action_pressed("backward"):
		direction += transform.basis.z

	
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x

		
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
	
	direction.normalized()
	animation_tree.set("parameters/strafe/blend_position", -Vector2(direction.z, direction.x))
	print(rotation_degrees.y)

	acceleration = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction*speed, acceleration*delta)

	var floor_normal = get_floor_normal()
	
	if is_on_floor():
		if direction.length_squared() < 0.1:
			y_velocity = -floor_normal.y * gravity
	
	else:
		y_velocity = clamp(y_velocity - gravity, 
							-max_terminal_velocity, max_terminal_velocity) 
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		animation_tree.set("parameters/jump/active", true)
		y_velocity = jump_power
		floor_normal = Vector3.ZERO
		
	velocity.y = y_velocity
	move_and_slide_with_snap(velocity, floor_normal, Vector3.UP, true, 4, deg2rad(50))


