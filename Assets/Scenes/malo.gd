extends CharacterBody2D
@onready var player = get_node("/root/Node2D/Nauto")
@onready var interact = $InteractPrompt

func _ready() -> void:
	$Sprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	#print(position.distance_to(player.position))
	if position.distance_to(player.position) < 130 and Global.MODE == "Nauto" and Global.FREEZE == false:
		interact.visible = true
		Global.INTERACTABLE = true
	if Global.INTERACTABLE == false:
		interact.visible = false
		
