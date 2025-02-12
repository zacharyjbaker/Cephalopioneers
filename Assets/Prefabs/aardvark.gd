extends CharacterBody2D

@onready var sprite = $Aardvark

@export var speed = 100
@export var max_speed = 300.0
@export var y_knockback = 250
@export var x_knockback = 0
@export var upside_down = false
var waypoint_num = 0
var current_waypoint
var has_waypoints = false
var waypoints

func _ready() -> void:
	if upside_down == true:
		sprite.play("IdleUpsideDown")
	else:
		sprite.play("Idle")
	if get_child_count() > 0:
		has_waypoints = true
		waypoints = $Waypoints
		current_waypoint = 0
		#waypoint_num = waypoints.get_child_count() - 1
	print(waypoints.get_children())
		

func _physics_process(delta: float) -> void:
	# Sets orientation of body
	if position.x > waypoints.get_child(current_waypoint).position.x:
		if upside_down == true:
			scale.x = -1 * abs(scale.x)
		else:
			scale.x = -1 * abs(scale.x)
		#rotation_degrees = 180
		#sprite.flip_h = true
		#direction = 1
	elif position.x < waypoints.get_child(current_waypoint).position.x:
		if upside_down == true:
			scale.x = abs(scale.x)
		else:
			scale.x = abs(scale.x)
		
		#rotation_degrees = 0
		#sprite.flip_h = false
		#direction = -1
			
	if has_waypoints == true:
		if abs(position.x - waypoints.get_child(current_waypoint).position.x) < 10:
			if (waypoints.get_child(current_waypoint + 1) == null):
				current_waypoint = 0
			else:
				current_waypoint += 1
		position.x = move_toward(position.x, waypoints.get_child(current_waypoint).position.x, speed * delta)
	
