extends CharacterBody2D
@onready var sprite = $Needlenose
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D

@export var tag = "Needlenose"
@export var speed = 170
@export var charge_speed = 800
@export var max_speed = 370
@export var charge_max_speed = 1000
@export var random_turn_timer_min = 1.0
@export var random_turn_timer_max = 6.0
@export var distance_threshold = 50
@export var stop_threshold = 50
@export var degrees_per_second = 90
@export var gravity = 0

var smashed = false
var fall_start = false
var mech_moved = false

# Vars for random enemy orientation
var random_dir_x = false 
var random_dir_y = false
var rng = RandomNumberGenerator.new()

# Targeting vars
var target = null
var player = null
var mech = null
var pilot = null

# Signals
signal bgmusic_chase
signal bgmusic_stop
signal bgmusic_rumble

enum States {IDLE, CHASE, CS_SHAKE, CS_DEVOUR, CS_MOVE, CS_ROAR, CS_FALL, CS_FALL_ROAR, CS_END}

var state: States = States.IDLE

func _ready() -> void:
	var dg_manager = get_node("/root/Node2D/DialogueManager")
	dg_manager.cs_eel.connect(cutscene)
	player = get_node("/root/Node2D/Nauto")
	player.cs_break.connect(break_cutscene)
	mech = get_node("/root/Node2D/Mech")
	pilot = get_node("/root/Node2D/Mech/Pilot")
	anim.play("Idle")
	
func break_cutscene():
	if fall_start == false:
		fall_start = true
		state = States.CS_FALL
		velocity.y = 0
		position.x = player.position.x - 2500
		position.y = player.position.y
		#set_rotation_degrees(90)
		#scale.x = scale.x * -1
		anim.play("Idle")
		timer.start(4)
		print ("CS_FALL")
	elif state == States.CS_FALL_ROAR:
		timer.start(2)
		audio.play()
		anim.play("Roar")
		print ("CS_FALL_ROAR")

func cutscene():
	Global.EEL_CUTSCENE = true
	if state == States.IDLE:
		Global.FREEZE = true
		state = States.CS_DEVOUR
		timer.start(4)
		print ("devour")
		#bgmusic_stop.emit()
	elif state == States.CS_DEVOUR:
		Global.SHAKE = false
		state = States.CS_MOVE
		#position.x = player.x - 150
		#position.y = player.y
		timer.start(3)
		print ("moving")
		bgmusic_stop.emit()
	elif state == States.CS_MOVE:
		state = States.CS_ROAR
		timer.start(2)
		print ("roar")
		velocity.x = 0
		mech.velocity.x += 1000
		mech.velocity.y -= 1000
		smashed = true
		Global.SHAKE = true
		audio.play()
		anim.play("Roar")
	elif state != States.CS_FALL and state != States.CS_FALL_ROAR and state != States.CS_END:
		timer.start(2)
		#print ("chase")
		state = States.CHASE
		Global.SHAKE = false
		if mech_moved == false:
			mech_moved = true
			mech.velocity.x = 0
			mech.velocity.y = 0
			mech.global_position.x = 32542
			mech.global_position.y = 1043
			pilot.global_position.x = 32542 - 4
			pilot.global_position.y = 1043 - 21
			Global.DAMAGED = true
			#pilot.velocity.x = 0
			#pilot.velocity.y = 0
			#mech.scale.x = -1
		
func _on_timer_timeout() -> void:
	if state == States.CS_FALL:
		state = States.CS_FALL_ROAR
		break_cutscene()
	elif state == States.CS_FALL_ROAR:
		print ("Timeout")
		anim.play("Nom")
		state = States.CS_END
	if state == States.CS_DEVOUR:
		velocity.y = 0
		position.x = player.position.x - 1500
		position.y = player.position.y - 150
		set_rotation_degrees(90)
		scale.x = -2
		Global.SHAKE = true

	if state == States.CS_ROAR:
		#velocity.x = 0
		anim.play("Nom")
		bgmusic_chase.emit()
		Global.SHAKE = false
		Global.FREEZE = false
	if state != States.CS_FALL or state != States.CS_FALL_ROAR:
		cutscene()
	
func _physics_process(delta: float) -> void:
	#if smashed == true:
		#print ("smashed_mech")
		#mech.rotation_degrees += delta * 90
			
	if state == States.CS_DEVOUR:
		velocity.y -= speed * 10 * delta
	
	elif state == States.CS_MOVE:
		var vector = player.global_position - self.global_position
		#look_at(player.global_position)
		#print (position.distance_to(player.global_position))
		if position.distance_to(player.global_position) < 500:
			velocity.x = 0
		else:
			velocity.x += speed * 3 * delta
	elif state == States.CS_FALL:
		var vector = player.global_position - self.global_position
		#look_at(player.global_position)
		print (position.distance_to(player.global_position))
		if position.distance_to(player.global_position) < 820:
			velocity.x = 0
		else:
			velocity.x += speed * 2 * delta
	elif state == States.CHASE:
		# Sets orientation of body
		var vector = player.global_position - self.global_position
		var end = abs(global_position.x - mech.global_position.x)
		#look_at(player.global_position)
		if end < 3500:
			if velocity.x > 0:
				velocity.x -= 4
		else:
			if velocity.x < max_speed:
				velocity.x += speed * delta
			if (position.y == player.global_position.y - 120):
				velocity.y = 0
			elif (position.y > player.global_position.y - 120):
				if velocity.y > 0:
					velocity.y -= 5
				if velocity.y > -400:
					velocity.y -= speed/2 * delta
			elif (position.y < player.global_position.y - 120):
				if velocity.y < 0:
					velocity.y += 5
				if velocity.y < 400:
					velocity.y += speed/2 * delta
			#if position.y >= player.global_position.y - 50:
				#position.move_toward(Vector2(position.x, player.global_position.y), 100)
	#velocity.y += speed * delta
	elif state == States.CS_END:
		velocity.x = 25
	move_and_slide()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Malo":
		body.queue_free()
	if body.name == "Nauto" and Global.FREEZE == false:
		body.queue_free()
	if body.is_in_group("Enemy"):
		body.queue_free()
	if body.is_in_group("NPC"):
		body.queue_free()
