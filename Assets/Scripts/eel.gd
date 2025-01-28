extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer

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
var target = null
var player = null

enum States {IDLE, CHASE, CS_SHAKE, CS_DEVOUR, CS_ROAR}

var state: States = States.IDLE

func _ready() -> void:
	var dg_manager = get_node("/root/Node2D/DialogueManager")
	dg_manager.cs_eel.connect(cutscene)
	player = get_node("/root/Node2D/Nauto")

func cutscene():
	print ("advancing cutscene")
	if state == States.IDLE:
		state = States.CS_DEVOUR
		timer.start(2)
	elif state == States.CS_DEVOUR:
		Global.SHAKE = false
		state = States.CS_ROAR
		timer.start(2)
	else:
		state = States.CHASE
		
func _on_timer_timeout() -> void:
	cutscene()
	
func _physics_process(delta: float) -> void:
	if state == States.CS_DEVOUR:
		velocity.y -= speed * 10 * delta
	
	elif state == States.CS_ROAR:
		velocity.y += speed * delta
		
	elif state == States.CHASE:
		# Sets orientation of body
		var vector = player.global_position - self.global_position
		#look_at(player.global_position)
		if velocity.x < max_speed:
			velocity.x += speed * delta
		position.y = player.global_position.y
	#velocity.y += speed * delta
	move_and_slide()
