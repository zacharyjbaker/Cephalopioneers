extends CharacterBody2D
@export var player : Node2D
@onready var interact = $InteractPrompt

func _ready() -> void:
	$Sprite2D.play("Idle")
	match Global.CONTROLSET:
		"kb":
			interact.play("kb")
		"cont":
			interact.play("cont")


func _physics_process(delta: float) -> void:
	#print(position.distance_to(player.position))
	if is_instance_valid(Global):
		if is_instance_valid(player):
			if position.distance_to(player.position) < 180 and Global.MODE == "Nauto" and Global.FREEZE == false:
				interact.visible = true
				Global.INTERACTABLE = true
			else:
				Global.INTERACTABLE = false
				interact.visible = false
		
