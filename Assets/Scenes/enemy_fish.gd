extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer
@onready var view_collider = $ViewCone
@onready var mode = $Mode

@export var tag = "Needlenose"
@export var SPEED = 100
@export var MAX_SPEED = 40.0

var player = null
var target = null
var original_scale = null
var direction = null
var search_cooldown = false
var cooldown_timer = false
var reached_target = false
var rotation_timer = false
var rotation_charge = false
var dir_to_player = null
var random_dir_x = false
var random_dir_y = false
var state = ""
var rng = RandomNumberGenerator.new()

var amplitude = 20.0
var frequency = 3.0
var harmonic_wave

func _ready() -> void:
	#original_scale = scale
	#sprite.flip_h = false
	mode.visible = false
	state = "Swim"
	timer.start(3)
	player = get_node("/root/Node2D/Nauto")
	

func _physics_process(delta: float) -> void:
	#print (timer.time_left)
	print (state)
	#print (scale)
	#print (velocity)
	#print (rotation_charge) 
	sprite.play("Swim")
	if (state == "Swim"):
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
			
	if (state == "Attack"):
		#print ("Enemy Pos:", position)
		if (position.distance_to(target) < 50 or reached_target == true):
			reached_target = true
			print ("Player position reached")
			if velocity.x > 1:
				scale.y = -1 * abs(scale.y)
				rotation_degrees = 180

			elif velocity.x < -1:
				scale.y = abs(scale.y)
				rotation_degrees = 0

			if (abs(velocity.x) < 50 and abs(velocity.y) < 50):
				velocity.x = 0
				velocity.y = 0
				reached_target = false
				if (cooldown_timer == false):
					print ("Start Cooldown")
					mode.play("Cooldown")
					if (rotation_degrees >= 180):
						mode.flip_h = true
					timer.start(5)
					velocity.x = 0
					velocity.y = 0
					state = "Swim"
					cooldown_timer = true
			elif velocity.x != 0 and velocity.y != 0:
				velocity.x = move_toward(velocity.x, 0, SPEED/3.5)
				velocity.y = move_toward(velocity.y, 0, SPEED/3.5)		
				
		if (rotation_charge == false):
			#print ("Rotate")
			velocity = Vector2(0,0)
			if (rotation_timer == false):
				timer.start(2)
				rotation_timer = true
			look_at(target)
			rotation_degrees += 180
			
			
		elif (rotation_charge == true):
			#print ("Moving toward target:", target)
			if (abs(velocity.x) < 1000):
				velocity.x += direction.x * SPEED * 10 * delta
			if (abs(velocity.y) < 1000):
				velocity.y += direction.y * SPEED * 10 * delta
	elif (search_cooldown == false):
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
	
	if state == "Attack" and rotation_charge == false:
		print ("Rotated")
		rotation_charge = true
		timer.stop()
		
	elif cooldown_timer == true:
		print ("Aggro Recharged")
		cooldown_timer = false
		rotation_timer = false
		rotation_charge = false
		search_cooldown = false
		mode.visible = false
		mode.flip_h = false
		timer.start(3)

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
	if body == player and state == "Swim" and search_cooldown == false:
		target = body.global_position
		direction = global_position.direction_to(target)
		timer.stop()
		print ("Player Detected")
		state = "Attack"
		mode.visible = true
		mode.play("Detected")
		search_cooldown = true
		#rotation_degrees = 0
		
#func _on_view_cone_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#timer.start(3)
