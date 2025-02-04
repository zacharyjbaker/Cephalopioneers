extends CharacterBody2D
@onready var mech_body_sprite = $MechBody
@onready var mech_front_arm = $FrontArm
@onready var mech_back_arm = $BackArm
@onready var pilot = $Pilot
@onready var camera = $MechCamera
#@onready var shader = $MechCamera/WaterShader

@export var jump_impulse = 200
var laser_projectile = preload("res://Assets/Prefabs/laser_projectile.tscn")

var current_anim = ""
var gravity_offset = 0
@export var hover_height = 140
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

func _ready() -> void:
	mech_front_arm.play("Idle")
	mech_back_arm.play("Idle")
	mech_body_sprite.play("Idle")
	original_scale.x = camera.scale.x
	original_scale.y = camera.scale.y
	original_rotation = camera.rotation_degrees
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
	
func close_anim():
	isClosing = true
	current_anim = "Close"
	mech_body_sprite.play(current_anim)
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
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

	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180

	#print (Global.MODE)
	#print (floor_height)
	if (!isHovering):
		velocity.y += delta * (Global.GRAVITY - gravity_offset)
	
	if !is_on_floor() and !(Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		if Global.MODE == "Mech":
			mech_body_sprite.play("Boost")
		else:
			mech_body_sprite.play("BoostOpen")
			mech_back_arm.stop()	
			mech_front_arm.stop()	
	
	if is_on_floor():
		floor_height = global_position.y
		
	if isDrilling == true:
		mech_back_arm.play("Drill")
		
	elif isDrilling == false:
		mech_back_arm.play("Idle")
	
	if (Global.MODE == "Mech" and isClosing == false):
		# charge jump anim
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			#print ("Hover Right")
			hover_move_anim()
			if velocity.x < (Global.WALK_SPEED - 150):
				velocity.x +=  Global.WALK_SPEED * delta * 1.5
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
				isHovering = true
		
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			#print ("Hover Right")
			hover_move_anim()
			if velocity.x > -(Global.WALK_SPEED - 150):
				velocity.x +=  -Global.WALK_SPEED * delta * 1.5
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
				isHovering = true
				
		elif Input.is_action_pressed("ui_up"):
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
				isHovering = true
				velocity.x = 0
				if global_position.y - (floor_height - hover_height) <= 5:
					position.y = (floor_height - hover_height)
		else:
			isHovering = false
			
		# move anims
		if Input.is_action_pressed("ui_right") and is_on_floor() and !Input.is_action_pressed("ui_up"):
			move_anim()
			if velocity.x < (Global.WALK_SPEED - 250):
				velocity.x +=  Global.WALK_SPEED * delta * 1
			if velocity.x > (Global.WALK_SPEED - 250):
				velocity.x = (Global.WALK_SPEED - 250)
			#mech_body_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left") and is_on_floor() and !Input.is_action_pressed("ui_up"):
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
			if isDrilling == false:
				mech_back_arm.stop()
			isShooting = true
		if Input.is_action_just_pressed("back_arm"):
			isDrilling = true
		if Input.is_action_just_released("back_arm"):
			isDrilling = false
	else:
		if is_on_floor() and isClosing == false and isOpening == false:
			mech_body_sprite.play("IdleOpen")	
			mech_back_arm.stop()	
			mech_front_arm.stop()	

func shoot() -> void:
	var laser_proj_instance = laser_projectile.instantiate()
	
	if rotation_degrees == 0:
		laser_proj_instance.velocity.x = 1
		laser_proj_instance.position = position + Vector2(90, 45)
	else:
		laser_proj_instance.velocity.x = -1
		laser_proj_instance.position = position + Vector2(-90, 45)
	#print (velocity.norma	lized().x)
	get_tree().root.add_child(laser_proj_instance)

func _on_front_arm_frame_changed() -> void:
	print ("Shoot")
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
