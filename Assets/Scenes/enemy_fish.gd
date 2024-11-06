extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer
@onready var view_collider = $ViewCone
@onready var mode = $Mode

@export var tag = "Needlenose"
@export var SPEED = 100
@export var MAX_SPEED = 40.0

# Vars for random enemy orientation
var random_dir_x = false 
var random_dir_y = false
var rng = RandomNumberGenerator.new()

# Targeting vars
var player = null
var target = null
var targetBody = null
var direction = null

# State vars and bools
var state = ""
var isInViewCone = true
var isAttackReady = false
var isAttackCoolingDown = false
var isTargetReached = false
var isRotated = false
var isActivelyRotating = false

func _ready() -> void:
	#original_scale = scale
	#sprite.flip_h = false
	mode.visible = false
	state = "Swim"
	timer.start(3)
	player = get_node("/root/Node2D/Nauto")
	
func _physics_process(delta: float) -> void:
	#print (timer.time_left)
	#print (state)
	#print (scale)
	#print (velocity)
	#print (isActivelyRotating) 
	#print (isInViewCone)
	sprite.play("Swim")
	
	# Idle state
	if (state == "Swim"):
		
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
	if (state == "Attack"):
		#print ("Enemy Pos:", position)
		
		# If player positional target reached
		if (position.distance_to(target) < 50 or isTargetReached == true):
			isTargetReached = true
			print ("Player position reached")
			
			# Directonality of body
			if velocity.x > 1:
				scale.y = -1 * abs(scale.y)
				rotation_degrees = 180

			elif velocity.x < -1:
				scale.y = abs(scale.y)
				rotation_degrees = 0
			
			# When slowed down enough, stop and start aggro cooldown
			if (abs(velocity.x) < 50 and abs(velocity.y) < 50):
				velocity.x = 0
				velocity.y = 0
				isTargetReached = false
				if (isAttackCoolingDown == false):
					print ("Start Cooldown")
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
				velocity.x = move_toward(velocity.x, 0, SPEED/3.5)
				velocity.y = move_toward(velocity.y, 0, SPEED/3.5)		
				
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
			if (abs(velocity.x) < 1000):
				velocity.x += direction.x * SPEED * 10 * delta
			if (abs(velocity.y) < 1000):
				velocity.y += direction.y * SPEED * 10 * delta
				
	# Random idle movement speed
	elif (isAttackReady == false):
		if (random_dir_x):
			if (velocity.x < MAX_SPEED):
				velocity.x += SPEED * delta
		else:
			if (velocity.x > -MAX_SPEED):
				velocity.x -= SPEED * delta
		
		if (random_dir_y):
			if (velocity.y < MAX_SPEED):
				velocity.y += SPEED * delta
		else:
			if (velocity.y > -MAX_SPEED):
				velocity.y -= SPEED * delta
	move_and_slide()
	#velocity.x = move_toward(velocity.x, 0, SPEED)
	
func _on_timer_timeout() -> void:
	# After pause and rotation
	if state == "Attack" and isActivelyRotating == false:
		print ("Rotated")
		isActivelyRotating = true
		mode.visible = false
		timer.stop()
	
	# Aggro recharge
	elif isAttackCoolingDown == true:
		print ("Aggro Recharged")
		isAttackCoolingDown = false
		isRotated = false
		isActivelyRotating = false
		isAttackReady = false
		mode.visible = false
		mode.flip_h = false
		timer.start(3)
		if isInViewCone == true:
			enter_attack_state(targetBody)

	# Randomly switch direction of idle movement
	else:
		var random = rng.randf_range(-5.0, 5.0)
		if random < 0:
			random_dir_x = !random_dir_x
		elif random > 0:
			random_dir_x = random_dir_x
		random = rng.randf_range(-5.0, 5.0)
		if random < 0:
			random_dir_y = !random_dir_y
		elif random > 0:
			random_dir_y = random_dir_y
		timer.start(3)

func _on_view_cone_body_entered(body: Node2D) -> void:
	if body == player:
		isInViewCone = true
		if isAttackReady == false and state == "Swim":
			targetBody = body
			enter_attack_state(body)
		
func _on_view_cone_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	isInViewCone = false
	print ("Left Viewcone")
	
func enter_attack_state(body: Node2D) -> void:
	target = body.global_position
	direction = global_position.direction_to(target)
	timer.stop()
	print ("Player Detected")
	state = "Attack"
	mode.visible = true
	mode.play("Detected")
	isAttackReady = true
	#rotation_degrees = 0
