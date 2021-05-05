extends KinematicBody

export var speed := 10.0
export var acceleration := 15.0
export var air_acceleration := 5.0
export var gravity := .98
export var max_terminal_velocity := 54.0
export var jump_power := 10.0

export(float, 0.1, 1) var mouse_sensitivity := .3
export(float, -90, 0) var min_pitch := -50.0
export(float, 0, 90) var max_pitch := 30.0

var velocity :Vector3
var y_velocity :float
var snap = get_floor_normal()

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

	acceleration = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction*speed, acceleration*delta)
	
	if is_on_floor():
		pass
		#y_velocity -= .01
	else:
		y_velocity = clamp(y_velocity - gravity, 
							-max_terminal_velocity, max_terminal_velocity) 
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		y_velocity = jump_power
		snap = Vector3.ZERO
		
	velocity.y = y_velocity
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(90))


