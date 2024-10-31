extends CharacterBody2D
@onready var nauto_sprite = $Nauto
@onready var mech_sprite = $Mech
@onready var anim_player = $AnimationPlayer
@onready var mode = ""
@export var WALK_SPEED = 400
@export var JUMP_IMPULSE = 350
var current_anim = ""
var jumped = false
var falling = true
var play_anim = true
var boost = 0.0
var jump_delay = 1
const SCALE = 3.889
const GRAVITY = 400.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mech_sprite.set_process(false)
	mech_sprite.visible = false
	mode = "Nauto"

# Called every frame. 'delta' is the elap	sed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print (play_anim)
	velocity.y += delta * GRAVITY
	move_and_slide()
	
	# Shift mode
	if is_on_floor() and Input.is_action_just_pressed("ui_focus_next"):
		_shift_mode()
	# Nauto movement
	#if !(is_on_floor()):
		#nauto_sprite.play("Jump")
	if (mode == "Nauto"):
		#print (velocity.x)
		if velocity.y > 0:
			falling = true
			print ("PA:", play_anim)
			current_anim = "BeginFall"
			if play_anim == true:
				_fall_anim()
		elif velocity.y < 0:
			current_anim = "Ascend"
			nauto_sprite.play(current_anim)
			nauto_sprite.set_frame(1)
		if Input.is_action_just_released("ui_up"):
			_finish_jump()
			
		if Input.is_action_pressed("ui_up"):
			if is_on_floor() and jumped == false:
				#print ("pre-jump")
				current_anim = "Charge"
				nauto_sprite.play(current_anim)
				nauto_sprite.set_frame(1)
				nauto_sprite.stop()
				jumped = true
				#nauto_sprite.stop()
			elif is_on_floor():
				if (boost < 1):
					boost+=delta
				#print (boost)
				if (velocity.x > 50):
					velocity.x -= delta * 100
				elif (velocity.x < -50):
					velocity.x += delta * 100
				else:
					velocity.x = 0

		elif Input.is_action_pressed("ui_right"):
			#jumped = false
			if is_on_floor():
				falling = false
				play_anim = true
				nauto_sprite.play("Walk")
				current_anim = "Walk"
				if jumped != true and velocity.y == 0:
					#print ("right")
					if velocity.x < WALK_SPEED:
						velocity.x +=  WALK_SPEED * delta * 4
			else:
				#print ("right")
				if velocity.x < WALK_SPEED-150:
					velocity.x +=  WALK_SPEED * delta * 3
			nauto_sprite.flip_h = false
		elif Input.is_action_pressed("ui_left"):
			
			#jumped = false
			if is_on_floor():
				falling = false
				play_anim = true
				nauto_sprite.play("Walk")
				current_anim = "Walk"
				if jumped != true and velocity.y == 0:
					#print ("left")
					if velocity.x > -WALK_SPEED:
						velocity.x +=  -WALK_SPEED * delta * 4
			else:
				#print ("left")
				if velocity.x > -WALK_SPEED+150:
					velocity.x +=  -WALK_SPEED * delta * 3
			nauto_sprite.flip_h = true
		elif is_on_floor() and jumped == false:
			falling = false
			play_anim = true
			#print ("idle")
			current_anim = "Idle"
			#jumped = false
			nauto_sprite.play("Idle")
			
			if (velocity.x > 50):
				velocity.x -= delta * 2000
			elif (velocity.x < -50):
				velocity.x += delta * 2000
			else:
				velocity.x = 0

func _shift_mode() -> void:
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
	
func _finish_jump() -> void:
	if jumped == true:
		#print ("jump")
		velocity.y = -(JUMP_IMPULSE + boost * 300)
		boost = 0.0
		jumped = false
		
func _fall_anim() -> void:
	nauto_sprite.play(current_anim)
	play_anim = false		
