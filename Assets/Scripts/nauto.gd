extends CharacterBody2D

@onready var nauto_sprite = $Nauto
@onready var timer = $Timer
#@onready var mech_sprite = $/Node2D/Mech
@onready var nauto_camera = $NautoCamera
@onready var anim_player = $AnimationPlayer
@onready var mech_camera = get_node("/root/Node2D/Mech/MechCamera")
@onready var mech = get_node("/root/Node2D/Mech")
@onready var pilot_pos = get_node("/root/Node2D/Mech/Pilot").global_position

@export var jump_impulse = 350
@export var env_node : Node

var camera = null
var knockback = Vector2.ZERO
var current_anim = ""
var play_transition_anim = true
var boost = 0.0
var charge = false
var crouched = false
var isShiftingNauto = false

func _ready() -> void:
	#mech_sprite.set_process(false)
	#mech_sprite.visible = false
	nauto_camera.make_current()
	Global.MODE = "Nauto"
	
func _input(event)-> void:
	# Jump
	#print (global_position.distance_to(pilot_pos))
	if event.is_action_pressed("ui_up") and is_on_floor():
		charge_anim()
	# Shift mode
	elif mech.is_on_floor() and event.is_action_pressed("ui_focus_next") and position.distance_to(pilot_pos) < 250:
		print ("Shift")
		shift_mode()
	elif event.is_action_pressed("ui_down") and is_on_floor():
		#print ("crouched")
		crouched = !crouched
		if crouched:
			Global.WALK_SPEED = 150
			charge_anim()
		else:
			Global.WALK_SPEED = 400


func shift_mode() -> void:
	pilot_pos = get_node("/root/Node2D/Mech/Pilot").global_position
	if (Global.MODE == "Nauto"):
		mech.close_anim()
		mech_camera.make_current()
		#mech_camera.get_child(0).visible = true
		#nauto_camera.get_child(0).visible = false
		Global.MODE = "Mech"
		velocity = Vector2.ZERO
		visible = false
		get_node("PhysicsCollider").set_process(false)
		get_node("HurtBox").set_process(false)
		position = mech.position
	elif (Global.MODE == "Mech"):
		mech.open_anim()
		#mech_camera.get_child(0).visible = false
		#nauto_camera.get_child(0).visible = true
		Global.MODE = "Nauto"
		velocity = Vector2.ZERO
		isShiftingNauto = true
		timer.start(0.5)
	'''
	if (mode == "Nauto"):
		mech_sprite.set_process(true)
		nauto_sprite.set_process(false)
		nauto_sprite.visible = false
		mech_sprite.visible = true
		mode = "Mech"
	elif (mode == "Mech"):
		mech_sprite.set_process(false)
		nauto_sprite.set_process(true)
		mech_sprite.visible = false
		nauto_sprite.visible = true
		mode = "Nauto"
	'''
		
func move_anim():
	if crouched:
		current_anim = "CrouchWalk"
		nauto_sprite.play(current_anim)
	else:
		current_anim = "Walk"
		nauto_sprite.play(current_anim)
		
func charge_anim():
	current_anim = "Charge"
	nauto_sprite.play(current_anim)
		
func finish_jump() -> void:
	velocity.y = -(jump_impulse + boost * 300)
	#nauto_sprite.self_modulate = original_modulate
	boost = 0.0

func fall_anim() -> void:
	if !is_on_floor():
		current_anim = "BeginFall"
		nauto_sprite.play(current_anim)

func _physics_process(delta: float) -> void:
	#print (position)
	velocity.y += delta * Global.GRAVITY 
	move_and_slide()
	
	if velocity.x > 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0
	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
	
	if (Global.MODE == "Mech"):
		position = pilot_pos
	
	# Nauto movement
	elif (Global.MODE == "Nauto"):
		if velocity.y > 0: # falling transition anim
			if play_transition_anim == true:
				fall_anim()
				play_transition_anim = false		
		elif velocity.y < 0: # ascending transition anim
			current_anim = "Ascend"
			nauto_sprite.play(current_anim)
			
		# charge jump anim
		if Input.is_action_pressed("ui_up") and is_on_floor():
			charge = true;
			if crouched:
				crouched = false
				Global.WALK_SPEED = 400
			if (boost < 1):
				boost+=delta
				#nauto_sprite.self_modulate = Color(0,0,boost*2, 100)
			if (velocity.x > 50):
				velocity.x -= delta * 150
			elif (velocity.x < -50):
				velocity.x += delta * 150
			else:
				velocity.x = 0
				
		elif Input.is_action_just_released("ui_up") and charge == true and is_on_floor():
			charge = false
			finish_jump()
			
		elif Input.is_action_just_released("ui_down") and is_on_floor():
			if (velocity.x > 50):
				velocity.x -= delta * 10000
			elif (velocity.x < -50):
				velocity.x += delta * 10000
			
		# move anims
		elif Input.is_action_pressed("ui_right"):
			if is_on_floor():
				move_anim()
				play_transition_anim = true	
				if velocity.x < Global.WALK_SPEED:
					velocity.x +=  Global.WALK_SPEED * delta * 4
			else:
				if velocity.x < Global.WALK_SPEED - 150:
					velocity.x +=  Global.WALK_SPEED * delta * 3
			#nauto_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left"):
			if is_on_floor():
				move_anim()
				play_transition_anim = true
				if velocity.x > -Global.WALK_SPEED:
					velocity.x +=  -Global.WALK_SPEED * delta * 4
			else:
				if velocity.x > -Global.WALK_SPEED + 150:
					velocity.x +=  -Global.WALK_SPEED * delta * 3
			#nauto_sprite.flip_h = true
			
		elif is_on_floor():
			if crouched == false:
				current_anim = "Idle"
			else:
				current_anim = "Charge"
			nauto_sprite.play(current_anim)
			play_transition_anim = true
			if (velocity.x > 50):
				velocity.x -= delta * 2000
			elif (velocity.x < -50):
				velocity.x += delta * 2000
			else:
				velocity.x = 0

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if (body.get_node("HitBox").is_in_group("damage") and Global.MODE == "Nauto"):
		#print ("hit")
		#velocity.x += body.velocity.x * 3
		velocity.x += -(velocity.x * 2 + 50) + body.velocity.x / 2.0
		#velocity.y += body.velocity.y * 3
		velocity.y += -(velocity.y * 2 + 50) + body.velocity.x / 2.0
		Global.HEALTH -= 1
		#print (env_node.environment.glow_intensity)
		env_node.set_glow(1)

func _on_timer_timeout() -> void:
	if isShiftingNauto == true:
		isShiftingNauto = false
		mech.velocity = Vector2.ZERO
		position.x = pilot_pos.x
		position.y = pilot_pos.y - 40
		scale = mech.scale * 4
		rotation_degrees = mech.rotation_degrees
		get_node("PhysicsCollider").set_process(true)
		get_node("HurtBox").set_process(true)
		visible = true
		nauto_camera.make_current()
