extends CharacterBody2D
@onready var anim_player = $AnimatedSprite2D
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

enum States {AMBUSH, READY, MIMIC, IDLE, WALK, WALKDRILL}

@export var state: States = States.AMBUSH
var player: Node2D = null
var flashlight: Node2D = null
var is_in_flashlight = false
var ambush_triggered = false
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	#timer.start(2)
	find_player()

func _physics_process(delta: float) -> void:
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
		
	if state == States.AMBUSH:
		var distance = global_position.x - player.global_position.x
		#print (distance)
		if abs(distance) < detection_range and ambush_triggered == false:
			#print("start")
			ambush_triggered = true
			timer.start(0.5)
			
	if state == States.WALK or state == States.WALKDRILL:
		if player:
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
			print (is_in_flashlight)
			if abs(distance) < aggro_range:
				if is_in_flashlight == true:
						velocity.x += delta * run_speed * sign(distance)
						if abs(velocity.x) > run_max_speed:
							velocity.x = sign(distance) * run_max_speed 
				else:
					velocity.x += delta * charge_speed * -sign(distance)
					if abs(velocity.x) > charge_max_speed:
						velocity.x = -sign(distance) * charge_max_speed

func _on_timer_timeout() -> void:
	if state == States.AMBUSH:
		anim_player.play("Ambush")
		state = States.READY
		var random_num = rng.randf_range(1.5, 5.0)
		timer.start(random_num) #will use random number
	elif state == States.READY:
		anim_player.play("Mimic")
		state = States.MIMIC
		timer.start(1)
	elif state == States.MIMIC:
		anim_player.play("Idle")
		state = States.IDLE
		timer.start(0.3)
	elif state == States.IDLE:
		anim_player.play("Walk")
		state = States.WALK
		#timer.start(3)
	#elif state == States.WALK:
		#anim_player.play("WalkDrill")
		#state = States.WALKDRILL
		#timer.start(4)
		
func find_player():
	player = get_tree().current_scene.get_node_or_null("Nauto")
	flashlight = get_tree().current_scene.get_node_or_null("FlashlightCone")
