extends Node2D

@onready var animation_player = $DoorSprite/AnimationPlayer

func open_door():
	if animation_player.has_animation("Door_Open"):
		print("Playing Door_Open animation")
		animation_player.play("Door_Open")
	else:
		print("Door_Open animation not found")
