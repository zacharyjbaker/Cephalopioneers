extends Camera2D

const CAMERA_MOVEMENT_SPEED : int = 4
@onready var shader = get_node("/root/Node2D/WaterShader")

# Camera screen limits from left boundary (pixels)
const CAMERA_LEFT_LIMIT : int = -1400
const CAMERA_RIGHT_LIMIT : int = 1920


func _physics_process(delta):
	shader.global_position.x = global_position.x
	shader.global_position.y = global_position.y
	
'''
	if (Input.is_action_pressed("ui_left") and position.x > CAMERA_LEFT_LIMIT):
		position.x -= CAMERA_MOVEMENT_SPEED
	if (Input.is_action_pressed("ui_right") and position.x < CAMERA_RIGHT_LIMIT):
		position.x += CAMERA_MOVEMENT_SPEED
'''
