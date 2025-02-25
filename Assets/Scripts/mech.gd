extends CharacterBody2D
@onready var mech_body_sprite = $MechBody
@onready var mech_front_arm = $FrontArm
@onready var mech_back_arm = $BackArm
@onready var drill_area = $DrillArea
@onready var drill_particles = $DrillArea/DrillParticles
@onready var laser_explosion_particles = $LaserExplosion
@onready var pilot = $Pilot
@onready var camera = $MechCamera
@onready var flashlight = $Flashlight
@onready var flashlight_cone = $FlashlightCone
@onready var cockpit_light = $Pilot/CockpitLight
@onready var boost_light = $BoostLight
@onready var boost_particles = $BoostParticles
@onready var back_boost_light = $BackBoostLight
@onready var back_boost_particles = $BackBoostParticles
@onready var player = get_node("/root/Node2D/Nauto")
@onready var interact = $InteractPrompt
@onready var blaster_player = $BlasterSFX
@onready var thruster_player = $ThrusterSFX
@onready var drill_player = $DrillSFX
#@onready var shader = $MechCamera/WaterShader

@export var blaster_sfx : Resource
@export var thruster_sfx : Resource
@export var drill_sfx : Resource

@export var jump_impulse = 200
var laser_projectile = preload("res://Assets/Prefabs/laser_projectile.tscn")

var current_anim = ""
var gravity_offset = 0
@export var hover_height = 180
var floor_height = 0
var original_scale = Vector2.ZERO
var original_rotation = 0
var original_shader_scale = Vector2.ZERO
var original_shader_rotation = 0

var isHovering = false
var isShooting = false
var isDrilling = false
var isOpening = false
var isClosing = false
var isThrusting = false
var isBuzzing = false

func _ready() -> void:
	mech_front_arm.play("Idle")
	mech_back_arm.play("Idle")
	mech_body_sprite.play("Idle")
	original_scale.x = camera.scale.x
	original_scale.y = camera.scale.y
	original_rotation = camera.rotation_degrees
	flashlight.enabled = false
	flashlight_cone.monitoring = false
	
	match Global.SCENE:
		"TheShallows":
			cockpit_light.enabled = false
		"WhalefallSettlement":
			cockpit_light.enabled = true
		_:
			pass
		
	#cockpit_light.enabled = false
	#drill_area.get_child(0).disabled = false
	#original_shader_scale.x = shader.scale.x
	#original_shader_scale.y = shader.scale.y
	#original_shader_rotation = shader.rotation_degrees
	
func _input(event)-> void:
	pass

func move_anim():
	current_anim = "Move"
	mech_body_sprite.play(current_anim)
	#print (position)	
	
func hover_move_anim():
	current_anim = "MoveBoost"
	mech_body_sprite.play(current_anim)
	#print (position)	
	
func shoot_anim():
	current_anim = "Shoot"
	mech_front_arm.play(current_anim)
	#print (position)	
	
func open_anim():
	isOpening = true
	current_anim = "Open"
	mech_body_sprite.play(current_anim)
	#cockpit_light.enabled = false
	#$AmbientLight.enabled = true
	
func close_anim():
	isClosing = true
	current_anim = "Close"
	mech_body_sprite.play(current_anim)
	interact.visible = false

	
func laser_explosion():
	pass
	#laser_explosion_particles.emitting = true
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
	if Global.MODE == "Nauto":
		if position.distance_to(player.position) < 250 and Global.FREEZE == false:
			interact.visible = true
		if position.distance_to(player.position) >= 250 :
			interact.visible = false
		
	
	pilot.global_position = Vector2(global_position.x - 4, global_position.y - 21)
	#print ("Mech:", position)
	#print (pilot.global_position)
	#print (isDrilling)
	#print (current_anim)
	#print ("close", isClosing)
	#print ("open", isOpening)
	
	# Sets orientation of body
	if velocity.x > 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0
		interact.scale.x = 4
		

	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
		interact.scale.x = -4

	#print (Global.MODE)
	#print (floor_height)
	if (!isHovering):
		velocity.y += delta * (Global.GRAVITY - gravity_offset)
	
	if !is_on_floor() and !(Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		if Global.DAMAGED == false:
			if Global.MODE == "Mech":
				mech_body_sprite.play("Boost")
				if isThrusting == false:
					thruster_player.stream = thruster_sfx
					thruster_player.play()
					isThrusting = true
			else:
				mech_body_sprite.play("BoostOpen")
				mech_back_arm.stop()	
				mech_front_arm.stop()	
		boost_light.enabled = true
		boost_particles.emitting = true
		back_boost_light.enabled = false
		back_boost_particles.emitting = false
	
	if is_on_floor():
		floor_height = global_position.y
		boost_light.enabled = false
		boost_particles.emitting = false
		back_boost_light.enabled = false
		back_boost_particles.emitting = false
		isThrusting = false
		thruster_player.stop()
		
	if isDrilling == true:
		mech_back_arm.play("Drill")
		if isBuzzing == false :
			drill_player.stream = drill_sfx
			drill_player.play()
			isBuzzing = true
		#drill_particles.emitting = true
		
	elif isDrilling == false:
		mech_back_arm.play("Idle")
		isBuzzing = false
		drill_player.stop()
		drill_particles.emitting = false
	
	if (Global.MODE == "Mech" and isClosing == false):
		# charge jump anim
		
		#cockpit_light.texture_scale = lerp(3.8, 2.4, 0.03)
		#cockpit_light.energy = lerp(1.1, 0.0, 0.01)
		
		#cockpit_light.enabled = true
		#$AmbientLight.enabled = false
		cockpit_light.energy = lerp(cockpit_light.energy, 1.1, 0.3 * delta)
		#print (cockpit_light.energy)
		cockpit_light.texture_scale = lerp(cockpit_light.texture_scale, 3.8, 0.9 * delta)
		#print (cockpit_light.texture_scale)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			#print ("Hover Right")
			hover_move_anim()
			boost_light.enabled = true
			boost_particles.emitting = true
			back_boost_light.enabled = true
			back_boost_particles.emitting = true
			if velocity.x < (Global.WALK_SPEED - 150):
				velocity.x +=  Global.WALK_SPEED * delta * 1.5
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
				isHovering = true
			if isThrusting == false:
				thruster_player.stream = thruster_sfx
				thruster_player.play()
				isThrusting = true
		
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			#print ("Hover Right")
			hover_move_anim()
			boost_light.enabled = true
			boost_particles.emitting = true
			back_boost_light.enabled = true
			back_boost_particles.emitting = true
			if velocity.x > -(Global.WALK_SPEED - 150):
				velocity.x +=  -Global.WALK_SPEED * delta * 1.5
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
				isHovering = true
			if isThrusting == false:
				thruster_player.stream = thruster_sfx
				thruster_player.play()
				isThrusting = true
				
		elif Input.is_action_pressed("ui_up"):
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				isHovering = true
				boost_light.enabled = true
				boost_particles.emitting = true
				back_boost_light.enabled = false
				back_boost_particles.emitting = false
				velocity.x = 0
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
		else:
			isHovering = false
			
		# move anims
		if Input.is_action_pressed("ui_right") and is_on_floor() and !Input.is_action_pressed("ui_up"):
			#print ("move_right")
			move_anim()
			if velocity.x < (Global.WALK_SPEED - 250):
				velocity.x +=  Global.WALK_SPEED * delta * 1
			if velocity.x > (Global.WALK_SPEED - 250):
				velocity.x = (Global.WALK_SPEED - 250)
			#mech_body_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left") and is_on_floor() and !Input.is_action_pressed("ui_up"):
			#print ("move_left")
			move_anim()
			if velocity.x > -(Global.WALK_SPEED - 250):
				velocity.x +=  -Global.WALK_SPEED * delta * 1
			if velocity.x < -(Global.WALK_SPEED - 250):
				velocity.x = -(Global.WALK_SPEED - 250)
			#mech_body_sprite.flip_h = true
			
		elif is_on_floor() and !Input.is_action_pressed("ui_up") and isClosing == false and isOpening == false:
			#gravity_offset = 0
			if (velocity.x > 50):
				velocity.x -= delta * 2000
			elif (velocity.x < -50):
				velocity.x += delta * 2000
			else:
				velocity.x = 0
			mech_body_sprite.play("Idle")
			
		
		if Input.is_action_just_pressed("front_arm"):
			shoot_anim()
			#print ("Shoot")
			if isHovering == false:
				mech_body_sprite.stop()
			#if isDrilling == false:
				#drill_area.monitorable = false
				#mech_back_arm.stop()
			isShooting = true
			#mech_front_arm.stop()
		elif isShooting == false:
			mech_front_arm.play("Idle")
		
		if Input.is_action_just_pressed("back_arm"):
			isDrilling = true
			#drill_area.get_child(0).disabled = true
			print ("Is Drilling")
		elif isDrilling == false:
			mech_back_arm.play("Idle")

		if Input.is_action_just_released("back_arm"):
			isDrilling = false
			#drill_area.get_child(0).disabled = false
			print ("Stop Drilling")
			
		if Input.is_action_just_pressed("flashlight"):
			if flashlight.enabled == true:
				flashlight.enabled = false
				flashlight_cone.monitoring = false
			else:
				flashlight.enabled = true
				flashlight_cone.monitoring = true
			
	else:
		if is_on_floor() and isClosing == false and isOpening == false:
			mech_body_sprite.play("IdleOpen")	
			mech_back_arm.stop()	
			mech_front_arm.stop()
		cockpit_light.energy = lerp(cockpit_light.energy, 0.9, 0.5 * delta)
		#print (cockpit_light.energy)
		cockpit_light.texture_scale = lerp(cockpit_light.texture_scale, 2.2, 1.4 * delta)
			

func shoot() -> void:
	var laser_proj_instance = laser_projectile.instantiate()
	blaster_player.stream = blaster_sfx
	blaster_player.play()
	
	if rotation_degrees == 0:
		laser_proj_instance.velocity.x = 1
		laser_proj_instance.position = position + Vector2(90, 60)
	else:
		laser_proj_instance.velocity.x = -1
		laser_proj_instance.position = position + Vector2(-90, 60)
	#print (velocity.norma	lized().x)
	get_tree().root.add_child(laser_proj_instance)

func _on_front_arm_frame_changed() -> void:
	#print ("Shoot")
	if isShooting == true and mech_front_arm.frame == 6:
		shoot()

func _on_front_arm_animation_finished() -> void:
	if isShooting == true:
		#shoot()
		mech_front_arm.play("Idle")
		mech_back_arm.play("Idle")
		mech_body_sprite.play("Idle")

func _on_mech_body_animation_finished() -> void:	
	if isClosing == true:
		isClosing = false
	if isOpening == true:
		isOpening = false

func _on_flashlight_cone_body_entered(body: Node2D) -> void:
	print ("Crab entered flashlight")
	if body.is_in_group("crab"):
		body.is_in_flashlight = true

func _on_flashlight_cone_body_exited(body: Node2D) -> void:
	print ("Crab exited flashlight")
	if body.is_in_group("crab"):
		body.is_in_flashlight = false
