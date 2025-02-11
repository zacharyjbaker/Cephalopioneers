extends Camera2D

const CAMERA_MOVEMENT_SPEED : int = 4
#@onready var shader = get_node("/root/Node2D/WaterShader")

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100,75) #Maximum displacement in pixels.
@export var max_roll := 0.1 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.



const CAMERA_LEFT_LIMIT : int = -1400
const CAMERA_RIGHT_LIMIT : int = 1920

var noise_y = 0
var shaking = false

var trauma := 0.0 #Current shake strength
var trauma_pwr := 3 #Trauma exponent. Use [2,3]

# Camera screen limits from left boundary (pixels)

func _ready():
	randomize()
	noise.seed = randi()

func add_trauma(amount : float):
	print ("shake called")
	shaking = true
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	#if (Input.is_action_pressed("ui_left") and position.x > CAMERA_LEFT_LIMIT):
		#position.x -= CAMERA_MOVEMENT_SPEED
	#if (Input.is_action_pressed("ui_right") and position.x < CAMERA_RIGHT_LIMIT):
		#position.x += CAMERA_MOVEMENT_SPEED
	
	if Global.SHAKE == true and shaking == false:
		decay = 0
		add_trauma(2)
	elif Global.SHAKE == false and shaking == true:
		decay = 0.9
		shaking = false
		
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x,0.0,1)
		lerp(offset.y,0.0,1)
		lerp(rotation,0.0,1)

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(0, noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(1000, noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(2000, noise_y)
	
	
