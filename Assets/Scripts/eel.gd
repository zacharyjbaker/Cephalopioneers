extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer
@onready var view_collider = $ViewCone
@onready var mode = $Mode
@onready var stun = $Stun

@export var tag = "Needlenose"
@export var speed = 100
@export var charge_speed = 800
@export var max_speed = 300
@export var charge_max_speed = 1000
@export var random_turn_timer_min = 1.0
@export var random_turn_timer_max = 6.0
@export var distance_threshold = 50
@export var stop_threshold = 50
@export var degrees_per_second = 90
@export var gravity = 0

# Vars for random enemy orientation
var random_dir_x = false 
var random_dir_y = false
var rng = RandomNumberGenerator.new()

# Targeting vars
var player = null
var target = null

func _ready() -> void:
	player = get_node("/root/Node2D/Nauto")
	
func _physics_process(delta: float) -> void:
	# Sets orientation of body
	var vector = player.global_position - self.global_position
	#look_at(player.global_position)
	if velocity.x < max_speed:
		velocity.x += speed * delta
	position.y = player.global_position.y
	#velocity.y += speed * delta
	move_and_slide()
