extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D
@export var WALK_SPEED = 400
@export var JUMP_IMPULSE = 400
var current_anim = ""
var jumped = false;
const SCALE = 3.889
const GRAVITY = 400.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elap	sed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += delta * GRAVITY
	move_and_slide()
	#if !(is_on_floor()):
		#animated_sprite.play("Jump")
	if (animated_sprite.animation_looped and jumped):
		print ("EndJump")
		jumped = false
		animated_sprite.stop()
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		print ("jump")
		current_anim = "Jump"
		animated_sprite.play(current_anim)
		jumped = true
		#animated_sprite.stop()
		velocity.y =  -JUMP_IMPULSE
	elif Input.is_action_pressed("ui_right"):
		print ("right")
		if is_on_floor():
			animated_sprite.play("Walk")
			current_anim = "Walk"
		velocity.x =  WALK_SPEED
		animated_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		print ("left")
		if is_on_floor():
			animated_sprite.play("Walk")
			current_anim = "Walk"
		velocity.x =  -WALK_SPEED
		animated_sprite.flip_h = true
	elif is_on_floor():
		#print ("idle")
		#current_anim = "Idle"
		animated_sprite.stop()
		velocity.x = 0
	
	
