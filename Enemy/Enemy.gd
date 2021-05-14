extends KinematicBody

export var speed := 5.0
export var acceleration := 10.0
export var gravity := .98

export(NodePath) onready var animation_tree = get_node(animation_tree)
onready var animation_state = animation_tree.get('parameters/playback')
onready var nav : Navigation= $"../lvl1/Navigation"
onready var player : KinematicBody= $"../Player"

var path := []
var velocity :Vector3
var current_node = 0

func _ready():
	pass

func _physics_process(delta):
	look_at(player.global_transform.origin, Vector3.UP)
	move_to_target(delta)

func move_to_target(delta):
	var direction: Vector3
	if current_node < path.size():
		direction = (path[current_node] - global_transform.origin)
		if direction.length() < 1:
			current_node += 1
			direction = direction.normalized()
			velocity = velocity.linear_interpolate(direction*speed, acceleration*delta)
			
		
			
		else:
			animation_state.travel('run')
			velocity.y -= .001
			move_and_slide(velocity, Vector3.UP)


func _on_PlayerTimer_timeout():
	current_node = 0
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
