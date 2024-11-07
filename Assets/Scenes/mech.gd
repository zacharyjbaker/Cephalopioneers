extends CharacterBody2D
@onready var mech_body_sprite = $MechBody
@onready var mech_front_arm = $FrontArm
@onready var mech_back_arm = $BackArm
@onready var pilot = $Pilot

@export var jump_impulse = 200

var current_anim = ""
var gravity_offset = 0
@export var hover_height = 140
var floor_height = 0

var isHovering = false
var isShooting = false
var isDrilling = false

func _ready() -> void:
	mech_front_arm.play("Idle")
	mech_back_arm.play("Idle")
	mech_body_sprite.play("Idle")
	
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
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	#print (pilot.global_position)
	#print (isDrilling)
	print (current_anim)
	
	# Sets orientation of body
	if velocity.x > 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0
		#sprite.flip_h = true
		#direction = 1
	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
		#sprite.flip_h = false
		#direction = -1
			
	#print (Global.MODE)
	#print (floor_height)
	if (!isHovering):
		velocity.y += delta * (Global.GRAVITY - gravity_offset)
	
	if !is_on_floor() and !(Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		mech_body_sprite.play("Boost")
	
	if is_on_floor():
		floor_height = global_position.y
		
	if isDrilling == true:
		mech_back_arm.play("Drill")
		
	elif isDrilling == false:
		mech_back_arm.play("Idle")
	
	if (Global.MODE == "Mech"):
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
			#mech_body_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left") and is_on_floor() and !Input.is_action_pressed("ui_up"):
			move_anim()
			if velocity.x > -(Global.WALK_SPEED - 250):
				velocity.x +=  -Global.WALK_SPEED * delta * 1
			#mech_body_sprite.flip_h = true
			
		elif is_on_floor() and !Input.is_action_pressed("ui_up"):
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
			isShooting = true
		if Input.is_action_just_pressed("back_arm"):
			isDrilling = true
		if Input.is_action_just_released("back_arm"):
			isDrilling = false
	else:
		if is_on_floor():
			mech_body_sprite.play("Idle")	

func _on_front_arm_animation_finished() -> void:
	if isShooting == true:
		mech_front_arm.play("Idle")
