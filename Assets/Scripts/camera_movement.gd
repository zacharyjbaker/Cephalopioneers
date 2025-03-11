extends Camera2D

const CAMERA_MOVEMENT_SPEED : int = 4

@export var decay := 0.8 # How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100, 75) # Maximum displacement in pixels.
@export var max_roll := 0.1 # Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite # The source of random values.

@onready var CityDoor = get_node("/root/Node2D/CityGate")
@onready var Cauldrons: Array
@onready var cam_timer = $CamTimer
@onready var player = get_parent() #Reference the Nauto Parent Node

const CAMERA_LEFT_LIMIT : int = -1400
const CAMERA_RIGHT_LIMIT : int = 1920

var noise_y = 0
var shaking = false
var panCamera = false
var reversePanCamera = false
var panToCauldron = false
var target_position: Vector2

var trauma := 0.0 # Current shake strength
var trauma_pwr := 3 # Trauma exponent. Use [2,3]

func _ready():
	randomize()
	noise.seed = randi()
	
	Cauldrons = [
	get_node("/root/Node2D/Cauldron"),
	get_node("/root/Node2D/Cauldron2"),
	get_node("/root/Node2D/Cauldron3"),
	get_node("/root/Node2D/Cauldron4")
	]

func add_trauma(amount : float):
	print("shake called")
	shaking = true
	trauma = min(trauma + amount, 1.0)

func _process(delta):
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
		offset.x = lerp(offset.x, 0.0, 0.1)
		offset.y = lerp(offset.y, 0.0, 0.1)
		rotation = lerp(rotation, 0.0, 0.1)
	
	if panCamera:
		Global.FREEZE = true
		global_position = global_position.lerp(CityDoor.global_position, 5 * delta)
		if global_position.distance_to(CityDoor.global_position) < 10:
			panCamera = false
			cam_timer.start(3)
	
	if reversePanCamera:
		#Use the player's current position from a Node2D-based child (e.g., a Sprite2D)
		var player_position = player.get_node("Nauto").global_position
		global_position = global_position.lerp(player_position, 5 * delta)
		if global_position.distance_to(player_position) < 10:
			print("reached back")
			reversePanCamera = false
			global_position = player_position
			Global.FREEZE = false
	
	if panToCauldron: #Handle panning to cauldrons
		Global.FREEZE = true
		global_position = global_position.lerp(target_position, 5 * delta)
		if global_position.distance_to(target_position) < 10:
			panToCauldron = false
			cam_timer.start(3)

func shake():
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(0, noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(1000, noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(2000, noise_y)

func dooropenlerp():
	panCamera = true

func cauldron_activated(cauldron_index: int):
	if cauldron_index >= 0 and cauldron_index < Cauldrons.size():
		target_position = Cauldrons[cauldron_index].global_position
		panToCauldron = true

func _on_cam_timer_timeout() -> void:
	print("Timeout")
	reversePanCamera = true
