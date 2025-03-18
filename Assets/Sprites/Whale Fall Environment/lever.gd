extends Area2D

@onready var PlayerCamera : Camera2D = get_node("../Nauto/NautoCamera")
@onready var door_player = $DoorSFX
@onready var lever_player = $LeverSFX
@export var door: NodePath  # Assign the door instance in the Inspector
var is_player_near = false
var is_pulled = false

func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact") and not is_pulled:
		pull_lever()

func pull_lever():
	is_pulled = true
	lever_player.play()
	if door:
		var door_node = get_node(door)
		if door_node.has_method("open_door"):
			door_node.open_door()
			PlayerCamera.dooropenlerp()
			print("working?")
			await get_tree().create_timer(1.2).timeout
			lever_player.stop()
			door_player.play()
		else:
			print("Door does not have an open_door method")
	else:
		print("Door not assigned")

func _on_area_entered(area):
	if area.is_in_group("player"):
		print("Player entered lever area")
		is_player_near = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		print("Player exited lever area")
		is_player_near = false
