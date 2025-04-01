extends CharacterBody2D
@onready var anim_player = $Crab
@onready var timer = $Timer
@onready var ambush_timer = $AmbushTimer

@export var run_speed = 800.0
@export var run_max_speed = 500.0
@export var charge_speed = 250.0
@export var charge_max_speed = 250.0
@export var aggro_range: float = 1400.0
@export var detection_range: float = 800.0
@export var y_knockback = 25
@export var x_knockback = 40
@export var crab_type = 1

enum States {AMBUSH, READY, MIMIC, IDLE, WALK, WALKDRILL}

@export var state: States = States.IDLE
var player: Node2D = null
var flashlight: Node2D = null
var is_in_flashlight = false
var ambush_triggered = false
var isWalking = false
var isIdling = true

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	velocity.x = 0
	velocity.y = 0
	#timer.start(2)
	anim_player.play("Idle")
	state = States.WALK
	find_player()

func _physics_process(delta: float) -> void:
	#print (position)
	velocity.y += delta * Global.GRAVITY 
	move_and_slide()
	
	if velocity.x < 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0
		#shader.flip_h = false
	elif velocity.x > -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
		#shader.flip_h = true
		
	if state == States.WALK:
		if player and is_on_floor():
			var distance =  global_position.x - player.global_position.x
			#print (velocity.x)
			#print (distance)
			#print (Global.MODE)
			'''
			if abs(distance) < aggro_range:
				if Global.MODE == "Nauto":
					velocity.x += delta * speed * -sign(distance)
					if abs(velocity.x) > max_speed:
						velocity.x = -sign(distance) * max_speed
				elif Global.MODE == "Mech":
					velocity.x += delta * speed * sign(distance)
					if abs(velocity.x) > max_speed:
						velocity.x = sign(distance) * max_speed 
			'''
			#print (is_in_flashlight)
			if abs(distance) < aggro_range:
				if !isWalking:
					anim_player.play("Walk")
					isWalking = true
					isIdling = false
				if is_in_flashlight == true:
					velocity.x += delta * charge_speed / 5 * -sign(distance)
					if abs(velocity.x) > charge_max_speed / 5:
						velocity.x = -sign(distance) * charge_max_speed / 5
				else:
					velocity.x += delta * charge_speed / 2.5 * -sign(distance)
					if abs(velocity.x) > charge_max_speed / 2.5:
						velocity.x = -sign(distance) * charge_max_speed / 2.5
			else:
				if !isIdling:
					isWalking = false
					anim_player.play("Idle")
					velocity.x = 0

'''
func _on_timer_timeout() -> void:

	if state == States.IDLE:
		print ("begin_walk")
		anim_player.play("Walk")
		state = States.WALK
		#timer.start(3)
	#elif state == States.WALK:
		#anim_player.play("WalkDrill")
		#state = States.WALKDRILL
		#timer.start(4)
'''
func find_player():
	player = get_tree().current_scene.get_node_or_null("Nauto")
	flashlight = get_tree().current_scene.get_node_or_null("FlashlightCone")
