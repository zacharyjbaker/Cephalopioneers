extends Node2D

@onready var animation_player = $DoorSprite/AnimationPlayer

func open_door():
	if animation_player.has_animation("Door_Open"):
		print("Playing Door_Open animation")
		animation_player.play("Door_Open")
		
	else:
		print("Door_Open animation not found")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Door_Open":
		animation_player.play("Door_Move_Up")
		get_node("StaticBody2D/CollisionShape2D").disabled = true
