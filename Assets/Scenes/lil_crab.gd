extends CharacterBody2D
@onready var anim_player = null
@onready var crab_sprite = $Crab
@onready var altcrab_sprite = $AltCrab
@onready var timer = $Timer
@onready var ambush_timer = $AmbushTimer
@onready var hit_box = $HitBox
@onready var scuttle_player = $ScuttleSFX
@onready var spawn_player = $SpawnSFX

@export var run_speed = 800.0
@export var run_max_speed = 500.0
@export var charge_speed = 250.0
@export var charge_max_speed = 250.0
@export var aggro_range: float = 1400.0
@export var detection_range: float = 800.0
@export var y_knockback = 25
@export var x_knockback = 40
@export var crab_type = 1
@export var player: Node2D

#@export var player : Node2D

enum States {AMBUSH, READY, MIMIC, IDLE, WALK, WALKDRILL}

@export var state: States = States.AMBUSH
var flashlight: Node2D = null
var is_in_flashlight = false
var ambush_triggered = false
var isScuttling = false
var isStun = false

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	#timer.start(2)
	velocity.x = 0
	velocity.y = 0
	#find_player()
	if crab_type == 1:
		altcrab_sprite.visible = false
		crab_sprite.visible = true
		anim_player = crab_sprite
	elif crab_type == 2:
		crab_sprite.visible = false
		altcrab_sprite.visible = true
		anim_player = altcrab_sprite
	#print ("anim:", anim_player)
	#print ("Player:", player)
	scuttle_player.connect("finished", restart_scuttle)

func _physics_process(delta: float) -> void:
	#find_player()
	if is_instance_valid(Global):
		#print (position)
		if abs(velocity.x) > 0 and !isScuttling:
			#print("scuttling")
			scuttle_player.play()
			isScuttling = true
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
		if is_on_floor():
			if state == States.AMBUSH:
				var distance = 0
				var y_distance = 0
				if is_instance_valid(player):
					distance = global_position.x - player.global_position.x
					y_distance = abs(global_position.y - player.global_position.y)
				else:
					distance = 100000000
					y_distance = 10000000
				#print (y_distance)
				if abs(distance) < detection_range and y_distance < 100 and ambush_triggered == false:
					#print("start")
					ambush_triggered = true
					timer.start(0.5)
				if velocity.x <= 10 and velocity.x >= -10:
					velocity.x = 0
				elif velocity.x > 0:
					velocity.x -= 100
				elif velocity.x < -1:
					velocity.x += 100
			elif state == States.MIMIC:
				if velocity.x <= 10 and velocity.x >= -10:
					velocity.x = 0
				elif velocity.x > 0:
					velocity.x -= 100
				elif velocity.x < -1:
					velocity.x += 100
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
					#print (is_in_flashlight)
					if isStun:
						velocity.x += delta * run_speed * sign(distance)
						if abs(velocity.x) > run_max_speed:
							velocity.x = sign(distance) * run_max_speed 
					else:
						if abs(distance) < aggro_range:
							if is_in_flashlight == true:
								velocity.x += delta * run_speed * sign(distance)
								if abs(velocity.x) > run_max_speed:
									velocity.x = sign(distance) * run_max_speed 
							else:
								velocity.x += delta * charge_speed * -sign(distance)
								if abs(velocity.x) > charge_max_speed:
									velocity.x = -sign(distance) * charge_max_speed
						else:
							velocity.x = 0
							#anim_player.play("Idle")

func _on_timer_timeout() -> void:
	if state == States.AMBUSH:
		anim_player.play("Ambush")
		state = States.READY
		var random_num = rng.randf_range(1.5, 5.0)
		timer.start(random_num) #will use random number
	elif state == States.READY:
		anim_player.play("Mimic")
		spawn_player.play()
		state = States.MIMIC
		timer.start(1)
	elif state == States.MIMIC:
		anim_player.play("Idle")
		state = States.IDLE
		hit_box.add_to_group("mech_damage")
		hit_box.add_to_group("mech_knockback")
		hit_box.add_to_group("damage")
		timer.start(0.3)
	elif state == States.IDLE:
		anim_player.play("Walk")
		
		state = States.WALK
		#timer.start(3)
	#elif state == States.WALK:
		#anim_player.play("WalkDrill")
		#state = States.WALKDRILL
		#timer.start(4)
	if isStun:
		isStun = false
		
func find_player():
	player = get_tree().current_scene.get_node_or_null("Nauto")
	flashlight = get_tree().current_scene.get_node_or_null("FlashlightCone")
	#print (player)
	
func restart_scuttle():
	print("fin scuttling")
	isScuttling = false
	

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if state == States.WALK:
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
				#mode.visible = false
				#stun.visible = true
				#stun.play("Stunned")
				#mode.play("Cooldown")
				#sprite.stop()
				timer.start(3.0)
