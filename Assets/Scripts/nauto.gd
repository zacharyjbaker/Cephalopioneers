extends CharacterBody2D

@onready var nauto_sprite = $Nauto
@onready var timer = $Timer
#@onready var mech_sprite = $/Node2D/Mech
@onready var nauto_camera = $NautoCamera
#@onready var shader = $WaterShader
@onready var anim_player = $AnimationPlayer
@onready var physics_collider = $PhysicsCollider
@onready var crouch_collider = $PhysicsColliderCrouch
@onready var self_light = $SelfLight

@onready var walk_player = $WalkSFX
@onready var charge_player = $ChargeSFX
@onready var jump_player = $JumpSFX
#@onready var mech_camera = get_node("/root/Node2D/Mech/MechCamera")

#@onready var mech = get_node("/root/Node2D/Mech")
@export var mech : Node2D
#@onready var pilot_pos = get_node("/root/Node2D/Mech/Pilot").global_position

#@onready var env_node = get_node("/root/Node2D/WorldEnvironment")
@export var env_node : WorldEnvironment
#@onready var breakable_floor = get_node("/root/Node2D/MiscEnv/BreakableFloor")
@export var misc_env : Node
@onready var charge_bar = $ChargeJumpBar
@onready var iFrames = $IFrames
#@onready var HP = get_node("/root/Node2D/UI/HP").get_children()
@export var HP_node : CanvasLayer

@export var iFrameTime = 1.2
@export var jump_impulse = 350

@export var save_load : Node2D

#@onready var pilot = mech.get_child(5)
var pilot = null
#@onready var mech_camera = mech.get_child(6)
var mech_camera = null
var breakable_floor = null
var breakable_particles = null
var pilot_pos = null
var HP = null
var camera = null
var knockback = Vector2.ZERO
var current_anim = ""
var play_transition_anim = true
var boost = 0.0
var charge = false
var crouched = false
var isShiftingNauto = false
var hasIFrames = false
var charging = false
var isWalking = false

enum States {IDLE, MOVE, STOP, SHOOT, FALL, FADE, CHANGE_SCENE}
signal cs_break
signal bgmusic_stop
signal bgmusic_rumble

var state: States = States.IDLE

func _ready() -> void:
	visible = true
	pilot = mech.get_node("Pilot")
	#@onready var mech_camera = mech.get_child(6)
	mech_camera = mech.get_node("MechCamera")
	pilot_pos = pilot.global_position
	HP = HP_node.get_node("HP").get_children()
	print ("HP Nodes:", HP)
	if is_instance_valid(misc_env):
		breakable_floor = misc_env.get_node("BreakableFloor")
		breakable_particles = misc_env.get_node("BreakableParticles")
	#if get_tree().current_scene.name == "TheShallows":
		
	#shift_mode()
	if is_instance_valid(Global):
		#mech_sprite.set_process(false)
		#mech_sprite.visible = false
		nauto_sprite.visible = true
		nauto_camera.make_current()
		Global.MODE = "Nauto"
		if is_in_group("player"):
			print("Nauto is in the player group!")
		
		#print ("Current Scene:", get_tree().get_current_scene().get_groups()[0])
		'''
		match get_tree().get_current_scene().get_groups()[0]:
			"TheShallows":
				self_light.enabled = false
			"WhalefallSettlement":
				self_light.enabled = true
			_:
				pass
		'''
	
	
	
func _input(event)-> void:
	if is_instance_valid(Global):
		pilot_pos = pilot.global_position
		#print (global_position.distance_to(pilot_pos))
		#print (mech.is_on_floor())
		# Jump 
		#print (global_position.distance_to(pilot_pos))
		if state == States.IDLE:
			if event.is_action_pressed("ui_up") and is_on_floor():
				charge_anim()
			# Shift mode
			elif (mech.is_on_floor() and event.is_action_pressed("ui_focus_next") and position.distance_to(pilot_pos) < 250):
				#Global.START = false
				print ("Shift")
				shift_mode()
			elif event.is_action_pressed("ui_down") and is_on_floor() and Global.MODE == "Nauto":
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
	if is_instance_valid(Global):
		pilot_pos = pilot.global_position
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
	print ("CS")
	if is_instance_valid(Global):
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
	if crouched == false:
		charge_bar.visible = true
		charge_bar.play("Charge")
		
func finish_jump() -> void:
	velocity.y = -(jump_impulse + boost * 300)
	charge_bar.visible = false
	charge_bar.play("Idle")
	#nauto_sprite.self_modulate = original_modulate
	boost = 0.0

func fall_anim() -> void:
	if !is_on_floor():
		current_anim = "BeginFall"
		nauto_sprite.play(current_anim)

func _physics_process(delta: float) -> void:
	if is_instance_valid(Global):
		if state == States.MOVE:
			mech.velocity.x = -100
			mech.move_anim()
			
		if abs(velocity.x) > 0 and !isWalking and is_on_floor() and Global.MODE == "Nauto":
			print("walking")
			walk_player.play()
			isWalking = true
			
		if abs(velocity.x) == 0 or !is_on_floor():
			walk_player.stop()
			isWalking = false
		
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
				#position = Vector2(29000, 1040)
				#_load_whalefall()
				health_loss()
			if velocity.y > 0: # falling transition anim
				if play_transition_anim == true:
					fall_anim()
					play_transition_anim = false		
			elif velocity.y < 0: # ascending transition anim
				current_anim = "Ascend"
				nauto_sprite.play(current_anim)
				
			# charge jump anim
			if Input.is_action_pressed("ui_up") and is_on_floor():
				#print("Boost:", boost)
				charge = true;
				physics_collider.disabled = true
				crouch_collider.disabled = false
				if !charging:
					charge_player.play()
					charging = true
				if crouched:
					crouched = false
					Global.WALK_SPEED = 400
				if (boost < 0.70):
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
				charge_player.stop()
				jump_player.play()
				charging = false
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
					charge_bar.visible = false
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
	if is_instance_valid(Global):
		if !hasIFrames:
			print ("Hurt by ", body.name)
			if body.get_node("HitBox"):
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
			if body.get_node("TempHitBox"):
				if (body.get_node("TempHitBox").is_in_group("damage") and Global.MODE == "Nauto"):
					#print ("hit")
					#velocity.x += body.velocity.x * 3
					velocity.x += -(velocity.x * 2 + body.x_knockback) + body.velocity.x / 2.0
					#velocity.y += body.velocity.y * 3
					velocity.y += -(velocity.y * 2 + body.y_knockback) + body.velocity.x / 2.0
					health_loss()
					#print (env_node.environment.glow_intensity)
					env_node.set_glow(1)
				if (body.get_node("TempHitBox").is_in_group("knockback") and Global.MODE == "Nauto"):
					#print ("hit")
					#velocity.x += body.velocity.x * 3
					#velocity.x += -(velocity.x * 2 + body.x_knockback) + body.velocity.x / 2.0
					#velocity.y += body.velocity.y * 3
					if body.is_in_group("aardvark") and body.upside_down == true:
						velocity.y += -(velocity.y * 2 + body.y_knockback)

func health_loss() -> void:
	print ("Lost hp")
	if Global.HEALTH > 0:
		Global.HEALTH -= 1
		HP[Global.HEALTH].visible = false
		print (HP[Global.HEALTH].name)
	hasIFrames = true
	iFrames.start(iFrameTime)
	
	if Global.HEALTH == 0:
		if Global.BOSS_FIGHT:
			Global.reset_globals_bossfight()
		else:
			Global.reset_globals()
		#Global.DIALOGUE_INSTANCE = 2
		save_load.load_game()
		velocity.x = 0
		#velocity.y = 0
		#rotation_degrees = 0

func _on_timer_timeout() -> void:
	if state == States.MOVE:
		state = States.STOP
		mech.velocity.x = 0
		mech.idle_anim()
		print ("Stop moving")
		cutscene()
	elif state == States.STOP:
		state = States.SHOOT
		mech.shoot_anim()
		mech.laser_explosion()
		print ("Shooting")
		cutscene()
	elif state == States.SHOOT:
		#bgmusic_stop.emit()
		bgmusic_rumble.emit()
		breakable_particles.visible = true
		state = States.FALL
		cutscene()
	elif state == States.FALL:
		breakable_floor.enabled = false
		state = States.FADE
		breakable_particles.one_shot = true
		cutscene()
	elif state == States.FADE:
		env_node.fade_to_black()
		timer.start(3)
		print ("fade to black")
		state = States.CHANGE_SCENE
	elif state == States.CHANGE_SCENE:
		_load_whalefall()
		#get_tree().change_scene_to_file("res://Assets/Scenes/WhalefallSettlement.tscn")
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


func _on_interaction_box_area_entered(area: Area2D) -> void:
	print("Nauto Collided")

func _on_i_frames_timeout() -> void:
	hasIFrames = false
	
func _load_whalefall() -> void:
	await get_tree().process_frame
	var current_scene = get_parent()
	for item in get_tree().get_nodes_in_group("instanced"):
		item.queue_free()
	var new_scene = ResourceLoader.load("res://Assets/Scenes/WhalefallSettlement.tscn")
	get_tree().get_root().add_child(new_scene.instantiate())
	#await get_tree().process_frame
	#Global.FREEZE = true
	current_scene.queue_free()
	
