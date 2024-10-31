extends CharacterBody2D

@onready var nauto_sprite = $Nauto
@onready var mech_sprite = $Mech
@onready var anim_player = $AnimationPlayer
@export var mode = ""
@export var JUMP_IMPULSE = 350
@export var GRAVITY = 400.0

var current_anim = ""
var play_transition_anim = true
var boost = 0.0
var charge = false
var crouched = false

func _ready() -> void:
	mech_sprite.set_process(false)
	mech_sprite.visible = false
	mode = "Nauto"
	
func _input(event)-> void:
	# Jump
	if event.is_action_pressed("ui_up") and is_on_floor():
		charge_anim()
	# Shift mode
	elif event.is_action_pressed("ui_focus_next") and is_on_floor():
		shift_mode()
	elif event.is_action_pressed("ui_down") and is_on_floor():
		print ("crouched")
		crouched = !crouched
		if crouched:
			Global.WALK_SPEED = 150
			charge_anim()
		else:
			Global.WALK_SPEED = 400
	
func shift_mode() -> void:
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
	velocity.y = -(JUMP_IMPULSE + boost * 300)
	#nauto_sprite.self_modulate = original_modulate
	boost = 0.0

func fall_anim() -> void:
	if !is_on_floor():
		current_anim = "BeginFall"
		nauto_sprite.play(current_anim)

func _physics_process(delta: float) -> void:
	#print (current_anim)
	velocity.y += delta * GRAVITY # gravity
	move_and_slide()
	
	# Nauto movement
	if (mode == "Nauto"):
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
			nauto_sprite.flip_h = false
			
		elif Input.is_action_pressed("ui_left"):
			if is_on_floor():
				move_anim()
				play_transition_anim = true
				if velocity.x > -Global.WALK_SPEED:
					velocity.x +=  -Global.WALK_SPEED * delta * 4
			else:
				if velocity.x > -Global.WALK_SPEED + 150:
					velocity.x +=  -Global.WALK_SPEED * delta * 3
			nauto_sprite.flip_h = true
			
		elif is_on_floor():
			if crouched == false:
				current_anim = "Idle"
			nauto_sprite.play(current_anim)
			play_transition_anim = true
			if (velocity.x > 50):
				velocity.x -= delta * 2000
			elif (velocity.x < -50):
				velocity.x += delta * 2000
			else:
				velocity.x = 0
