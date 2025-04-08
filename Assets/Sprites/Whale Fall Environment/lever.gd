extends Area2D

@export var Player : Node2D
@onready var LeverSound = $LeverSFX
@onready var DoorSound = $DoorSFX
@export var door: NodePath  # Assign the door instance in the Inspector
var is_player_near = false
var is_pulled = false

var PlayerCamera = null

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	print("DoorSound:", DoorSound)
	PlayerCamera = Player.get_node("NautoCamera")
func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact") and not is_pulled:
		pull_lever()

func pull_lever():
	is_pulled = true
	var sprite = $Sprite2D
	if sprite.material:
		print("Material exists, setting enabled=false")
		sprite.material.set_shader_parameter("onoff", 0)
	else:
		print("ERROR: No material found on sprite!")
	LeverSound.play()
	if door:
		var door_node = get_node(door)
		if door_node.has_method("open_door"):
			door_node.open_door()
			PlayerCamera.dooropenlerp()
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

func _on_lever_sfx_finished() -> void:
	print ("Door Sound")
	DoorSound.play()
