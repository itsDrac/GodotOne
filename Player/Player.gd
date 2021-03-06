extends KinematicBody

export var speed := 5.0
export var acceleration := 10.0
export var air_acceleration := 5.0
export var gravity := .98
export var max_terminal_velocity := 54.0
export var jump_power := 10

export(float, 0.1, 1) var mouse_sensitivity := .3
export(float, -90, 0) var min_pitch := -50.0
export(float, 0, 90) var max_pitch := 30.0
export(NodePath) onready var animation_tree = get_node(animation_tree)
export(NodePath) onready var attack_timer = get_node(attack_timer)

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
	var animation_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("forward") - Input.get_action_strength("backward")
	)

	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	
	
	elif Input.is_action_pressed("backward"):
		direction += transform.basis.z

	
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x

		
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
	
	direction.normalized()
	animation_tree.set("parameters/strafe/blend_position", animation_direction)

	acceleration = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction*speed, acceleration*delta)

	var floor_normal = get_floor_normal()
	
	if is_on_floor():
		if direction.length_squared() < 0.1:
			y_velocity = -floor_normal.y * gravity
		gravity = .98
		
		if Input.is_action_just_pressed("attack") and animation_direction == Vector2.ZERO:
			attack_timer.start()
			animation_tree.set("parameters/attack/active", true)
	
	else:
		y_velocity = clamp(y_velocity - gravity, 
							-max_terminal_velocity, max_terminal_velocity) 
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		animation_tree.set("parameters/jump/active", true)

		hang_air(delta)
		y_velocity += jump_power  
		floor_normal = Vector3.ZERO
		
	velocity.y = y_velocity
	move_and_slide_with_snap(velocity, floor_normal, Vector3.UP, true, 4, deg2rad(50))

func hang_air(delta):
	while gravity > .1 + delta:
		yield(get_tree(), "idle_frame")
		gravity = lerp(gravity, .1, 
		delta*4)
		print(gravity) # Problem(Bug) here

	yield(get_tree().create_timer(2.3), "timeout")
	gravity = 0.98


func _on_AttackTimer_timeout():
	animation_tree.set("parameters/attack_state/current", 1)
