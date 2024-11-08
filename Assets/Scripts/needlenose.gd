extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer
@onready var view_collider = $ViewCone
@onready var mode = $Mode
@onready var stun = $Stun

@export var tag = "Needlenose"
@export var speed = 100
@export var charge_speed = 800
@export var max_speed = 40.0
@export var charge_max_speed = 1000
@export var random_turn_timer_min = 1.0
@export var random_turn_timer_max = 6.0
@export var distance_threshold = 50
@export var stop_threshold = 50
@export var degrees_per_second = 90

# Vars for random enemy orientation
var random_dir_x = false 
var random_dir_y = false
var rng = RandomNumberGenerator.new()

# Targeting vars
var player = null
var target = null
var target_body = null
var direction = null

# State vars and bools
var state = ""
var isInViewCone = true
var isAttackReady = false
var isAttackCoolingDown = false
var isTargetReached = false
var isRotated = false
var isActivelyRotating = false
var isStun = false

func _ready() -> void:
	#original_scale = scale
	#sprite.flip_h = false
	mode.visible = false
	state = "Swim"
	sprite.play("Swim")
	#timer.start(3)
	random_direction_selection()
	player = get_node("/root/Node2D/Nauto")
	
func _physics_process(delta: float) -> void:
	#print (timer.time_left)
	#print (state)
	#print (scale)
	#print (velocity)
	#print (isActivelyRotating) 
	#print (isInViewCone)
	
	if isStun == true:
		rotation_degrees += delta * degrees_per_second
	
	# Idle state
	if (state == "Swim" and isStun == false):
		
		# Sets orientation of body
		if velocity.x > 1:
			scale.y = -1 * abs(scale.y)
			rotation_degrees = 180
			#sprite.flip_h = true
			#direction = 1
		elif velocity.x < -1:
			scale.y = abs(scale.y)
			rotation_degrees = 0
			#sprite.flip_h = false
			#direction = -1
	
	# Attack state
	if (state == "Attack" and isStun == false):
		#print ("Enemy Pos:", position)
		
		# If player positional target reached
		if (position.distance_to(target) < distance_threshold or isTargetReached == true):
			isTargetReached = true
			#print ("Player position reached")
			
			# Directonality of body
			if velocity.x > 1:
				scale.y = -1 * abs(scale.y)
				rotation_degrees = 180

			elif velocity.x < -1:
				scale.y = abs(scale.y)
				rotation_degrees = 0
			
			# When slowed down enough, stop and start aggro cooldown
			if (abs(velocity.x) < stop_threshold and abs(velocity.y) < stop_threshold):
				velocity.x = 0
				velocity.y = 0
				isTargetReached = false
				if (isAttackCoolingDown == false):
					#print ("Start Cooldown")
					mode.visible = true
					mode.play("Cooldown")
					if (rotation_degrees >= 180):
						mode.flip_h = true
					timer.start(5)
					velocity.x = 0
					velocity.y = 0
					state = "Swim"
					isAttackCoolingDown = true
			# Deccelerate 
			elif velocity.x != 0 and velocity.y != 0:
				velocity.x = move_toward(velocity.x, 0, speed/3.5)
				velocity.y = move_toward(velocity.y, 0, speed/3.5)		
				
		if (isActivelyRotating == false):
			#print ("Rotate")
			velocity = Vector2(0,0)
			
			# Pause and rotate toward player
			if (isRotated == false):
				timer.start(2)
				isRotated = true
			look_at(target)
			rotation_degrees += 180
			
		# Charge target post-rotation
		elif (isActivelyRotating == true):
			#print ("Moving toward target:", target)
			if (abs(velocity.x) < charge_max_speed):
				velocity.x += direction.x * charge_speed * delta
			if (abs(velocity.y) < charge_max_speed):
				velocity.y += direction.y * charge_speed * delta
				
	# Random idle movement speed
	elif (isAttackReady == false):
		if (random_dir_x):
			if (velocity.x < max_speed):
				velocity.x += speed * delta
		else:
			if (velocity.x > -max_speed):
				velocity.x -= speed * delta
		
		if (random_dir_y):
			if (velocity.y < max_speed):
				velocity.y += speed * delta
		else:
			if (velocity.y > -max_speed):
				velocity.y -= speed * delta
	move_and_slide()
	#velocity.x = move_toward(velocity.x, 0, speed)
	
func _on_timer_timeout() -> void:
	if isStun == true:
		isStun = false
		mode.visible = false
		stun.visible = false
		stun.stop()
		sprite.play("Swim")
		
	# After pause and rotation
	if state == "Attack" and isActivelyRotating == false:
		#print ("Rotated")
		isActivelyRotating = true
		mode.visible = false
		timer.stop()
	
	# Aggro recharge
	elif isAttackCoolingDown == true:
		#print ("Aggro Recharged")
		isAttackCoolingDown = false
		isRotated = false
		isActivelyRotating = false
		isAttackReady = false
		mode.visible = false
		mode.flip_h = false
		timer.start(3)
		if isInViewCone == true:
			enter_attack_state(target_body)

	# Randomly switch direction of idle movement
	else:
		random_direction_selection()
		
func random_direction_selection() -> void:
	var random_num = rng.randf_range(-5.0, 5.0)
	if random_num < 0:
		random_dir_x = !random_dir_x
	elif random_num > 0:
		random_dir_x = random_dir_x
	random_num = rng.randf_range(-5.0, 5.0)
	if random_num < 0:
		random_dir_y = !random_dir_y
	elif random_num > 0:
		random_dir_y = random_dir_y
	var random_time = rng.randf_range(random_turn_timer_min, random_turn_timer_max)
	timer.start(random_time)
	#print (name, ": ", random_dir_x, ": ", random_time)

func _on_view_cone_body_entered(body: Node2D) -> void:
	if body == player and Global.MODE == "Nauto":
		isInViewCone = true
		if isAttackReady == false and state == "Swim" and isStun == false:
			target_body = body
			enter_attack_state(body)
		
func _on_view_cone_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	isInViewCone = false
	#print ("Left Viewcone")
	
func _on_hurt_box_body_entered(body: Node2D) -> void:
	if !body.get_node("HitBox"):
		return
	if body.get_node("HitBox").is_in_group("laser"):
		print ("hit")
		body.queue_free()
		if isStun == false:
			#velocity.x += body.velocity.x * 3
			velocity.x = 0
			velocity.x += body.velocity.x / 8
			var random_num = rng.randf_range(-1.0, 1.0)
			velocity.y = 0
			velocity.y += body.velocity.x / 4 * random_num
			#print (env_node.environment.glow_intensity)
			isStun = true
			mode.visible = false
			stun.visible = true
			stun.play("Stunned")
			#mode.play("Cooldown")
			sprite.stop()
			timer.start(8.0)
		
	
func enter_attack_state(body: Node2D) -> void:
	target = body.global_position
	direction = global_position.direction_to(target)
	timer.stop()
	#print ("Player Detected")
	state = "Attack"
	mode.visible = true
	mode.play("Detected")
	isAttackReady = true
	#rotation_degrees = 0
