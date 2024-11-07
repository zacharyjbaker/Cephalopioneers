extends CharacterBody2D
@onready var mech_body_sprite = $MechBody
@onready var mech_front_arm = $FrontArm
@onready var mech_back_arm = $BackArm
@onready var pilot = $Pilot

@export var jump_impulse = 200

var current_anim = ""
var gravity_offset = 0
@export var hover_height = 90
var floor_height = 0

var isInAir = false

func _ready() -> void:
	mech_front_arm.play("Idle")
	mech_body_sprite.play("Idle")

func move_anim():
	current_anim = "Idle"
	mech_body_sprite.play(current_anim)
	#print (position)
	
func _physics_process(delta: float) -> void:
	print (pilot.global_position)
	
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
	if (!isInAir):
		velocity.y += delta * (Global.GRAVITY - gravity_offset)
	move_and_slide()
	
	if !is_on_floor():
		mech_body_sprite.play("Boost")

	else:
		floor_height = global_position.y
		mech_body_sprite.play("Idle")
	
	if (Global.MODE == "Mech"):
		# charge jump anim
		if Input.is_action_pressed("ui_up"):
			isInAir = true
			print (floor_height + hover_height)
			print ("G:",global_position.y)
			if (global_position.y > floor_height - hover_height):
				position.y += -(jump_impulse) * delta
			#gravity_offset = 400
			
		else:
			isInAir = false
			
		# move anims
		if Input.is_action_pressed("ui_right"):

			if velocity.x < Global.WALK_SPEED + 50:
				velocity.x +=  Global.WALK_SPEED * delta * 3
			#mech_body_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left"):
			if velocity.x > -Global.WALK_SPEED + 50:
				velocity.x +=  -Global.WALK_SPEED * delta * 3
			#mech_body_sprite.flip_h = true
			
		elif is_on_floor():
			#gravity_offset = 0
			if (velocity.x > 50):
				velocity.x -= delta * 2000
			elif (velocity.x < -50):
				velocity.x += delta * 2000
			else:
				velocity.x = 0
		
		if Input.is_action_pressed("ui_select"):
			mech_front_arm.play("Shoot")
