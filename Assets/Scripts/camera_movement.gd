extends Camera2D

const CAMERA_MOVEMENT_SPEED : int = 4

# Camera screen limits from left boundary (pixels)
const CAMERA_LEFT_LIMIT : int = -1400
const CAMERA_RIGHT_LIMIT : int = 1920

'''
func _process(delta):
	if (Input.is_action_pressed("ui_left") and position.x > CAMERA_LEFT_LIMIT):
		position.x -= CAMERA_MOVEMENT_SPEED
	if (Input.is_action_pressed("ui_right") and position.x < CAMERA_RIGHT_LIMIT):
		position.x += CAMERA_MOVEMENT_SPEED
'''
