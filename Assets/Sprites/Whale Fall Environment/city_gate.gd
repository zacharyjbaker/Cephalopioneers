extends Node2D

@onready var animation_player = $DoorSprite/AnimationPlayer
@onready var Particles1 = $DoorSprite/GPUParticles2D
@onready var Particles2 = $DoorSprite/GPUParticles2D2
@onready var Particles3 = $DoorSprite/GPUParticles2D3
@onready var Particles4 = $DoorSprite/GPUParticles2D4
@onready var Light1 = $DoorSprite/PointLight2D2
@onready var Light2 = $DoorSprite/PointLight2D3

func _ready() -> void:
	Particles1.visible = false
	Particles2.visible = false
	Particles3.visible = false
	Particles4.visible = false
	Light1.visible = false
	Light2.visible = false
func open_door():
	Particles1.visible = true
	Particles2.visible = true
	Particles3.visible = true
	Particles4.visible = true
	Light1.visible = true
	Light2.visible = true
	if animation_player.has_animation("Door_Open"):
		print("Playing Door_Open animation")
		animation_player.play("Door_Open")
		
	else:
		print("Door_Open animation not found")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Door_Open":
		animation_player.play("Door_Move_Up")
		get_node("StaticBody2D/CollisionShape2D").disabled = true
