extends CharacterBody2D

@onready var nauto_sprite = $Nauto
@onready var timer = $Timer
#@onready var mech_sprite = $/Node2D/Mech
@onready var nauto_camera = $NautoCamera
#@onready var shader = $WaterShader
@onready var anim_player = $AnimationPlayer
@onready var physics_collider = $PhysicsCollider
@onready var crouch_collider = $PhysicsColliderCrouch
@onready var mech_camera = get_node("/root/Node2D/Mech/MechCamera")
@onready var mech = get_node("/root/Node2D/Mech")
@onready var pilot_pos = get_node("/root/Node2D/Mech/Pilot").global_position
@onready var env_node = get_node("/root/Node2D/WorldEnvironment")
@onready var breakable_floor = get_node("/root/Node2D/MiscEnv/BreakableFloor")
@onready var HP = get_node("/root/Node2D/UI/HP").get_children()

@export var jump_impulse = 350


var camera = null
var knockback = Vector2.ZERO
var current_anim = ""
var play_transition_anim = true
var boost = 0.0
var charge = false
var crouched = false
var isShiftingNauto = false

enum States {IDLE, MOVE, STOP, SHOOT, FALL, FADE}
signal cs_break
signal bgmusic_stop
signal bgmusic_rumble

var state: States = States.IDLE

func _ready() -> void:
	#mech_sprite.set_process(false)
	#mech_sprite.visible = false
	nauto_camera.make_current()
	Global.MODE = "Nauto"
	
	
	
func _input(event)-> void:
	pilot_pos = get_node("/root/Node2D/Mech/Pilot").global_position
	#print (global_position.distance_to(pilot_pos))
	#print (mech.is_on_floor())
	# Jump 
	#print (global_position.distance_to(pilot_pos))
	if state == States.IDLE and Global.MODE == "Nauto":
		if event.is_action_pressed("ui_up") and is_on_floor():
			charge_anim()
		# Shift mode
		elif (mech.is_on_floor() and event.is_action_pressed("ui_focus_next") and position.distance_to(pilot_pos) < 250):
			#Global.START = false
			print ("Shift")
			shift_mode()
		elif event.is_action_pressed("ui_down") and is_on_floor():
			#print ("crouched")
			crouched = !crouched
			if crouched:
				Global.WALK_SPEED = 250
				velocity.x = velocity.normalized().x * Global.WALK_SPEED
				physics_collider.disabled = true
				crouch_collider.disabled = false
				charge_anim()
			else:
				Global.WALK_SPEED = 400
				physics_collider.disabled = false
				crouch_collider.disabled = true


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
	if Global.EEL_CUTSCENE == true:
		print ("Start floor cutscene")
		state = States.MOVE
		cutscene()
		
func cutscene():
	if state == States.MOVE:
		Global.FREEZE = true
		timer.start(3)
	elif state == States.STOP:
		timer.start(4)
		cs_break.emit()
	elif state == States.SHOOT:
		timer.start(1.5)
	elif state == States.FALL:
		timer.start(4)
		Global.SHAKE = true
	elif state == States.FADE:
		timer.start(4)

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
	if state == States.MOVE:
		mech.velocity.x = -100
		mech.move_anim()
	
	elif state == States.STOP:
		mech.velocity.x = 0
		mech.mech_body_sprite.play("Idle")
		
	elif state == States.SHOOT:
		mech.velocity.x = 0	
	
	#print (position)
	velocity.y += delta * Global.GRAVITY 
	move_and_slide()
	
	if velocity.x > 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0
		#shader.flip_h = false
	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
		#shader.flip_h = true
	
	if (Global.MODE == "Mech"):
		position = pilot_pos
		
	if (Global.FREEZE == true):
		velocity = Vector2(0,0)
	
	# Nauto movement
	elif (Global.MODE == "Nauto") and Global.FREEZE == false:
		if Input.is_action_just_pressed("debug_teleport"):
			position = Vector2(25400, 1040)
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
			physics_collider.disabled = true
			crouch_collider.disabled = false
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
			physics_collider.disabled = false
			crouch_collider.disabled = true
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
				if velocity.x < Global.WALK_SPEED - 75:
					velocity.x +=  Global.WALK_SPEED * delta * 4
			#nauto_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left"):
			if is_on_floor():
				move_anim()
				play_transition_anim = true
				if velocity.x > -Global.WALK_SPEED:
					velocity.x +=  -Global.WALK_SPEED * delta * 4
			else:
				if velocity.x > -Global.WALK_SPEED + 75:
					velocity.x +=  -Global.WALK_SPEED * delta * 4
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
	print ("Hurt by ", body.name)
	if (body.get_node("HitBox").is_in_group("damage") and Global.MODE == "Nauto"):
		#print ("hit")
		#velocity.x += body.velocity.x * 3
		velocity.x += -(velocity.x * 2 + body.x_knockback) + body.velocity.x / 2.0
		#velocity.y += body.velocity.y * 3
		velocity.y += -(velocity.y * 2 + body.y_knockback) + body.velocity.x / 2.0
		health_loss()
		#print (env_node.environment.glow_intensity)
		env_node.set_glow(1)
	if (body.get_node("HitBox").is_in_group("knockback") and Global.MODE == "Nauto"):
		#print ("hit")
		#velocity.x += body.velocity.x * 3
		#velocity.x += -(velocity.x * 2 + body.x_knockback) + body.velocity.x / 2.0
		#velocity.y += body.velocity.y * 3
		if body.is_in_group("aardvark") and body.upside_down == true:
			velocity.y += -(velocity.y * 2 + body.y_knockback)

func health_loss() -> void:
	Global.HEALTH -= 1
	HP[Global.HEALTH].visible = false

func _on_timer_timeout() -> void:
	if state == States.MOVE:
		state = States.STOP
		cutscene()
	elif state == States.STOP:
		state = States.SHOOT
		mech.shoot_anim()
		mech.laser_explosion()
		cutscene()
	elif state == States.SHOOT:
		#bgmusic_stop.emit()
		bgmusic_rumble.emit()
		state = States.FALL
		cutscene()
	elif state == States.FALL:
		breakable_floor.enabled = false
		state = States.FADE
		cutscene()
	elif state == States.FADE:
		env_node.fade_to_black()
		print ("fade to black")
	elif state == States.IDLE:
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
