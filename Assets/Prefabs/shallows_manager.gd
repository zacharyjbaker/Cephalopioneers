extends Node2D
@export var mech : Node2D
@export var player : Node2D

func _ready() -> void:
	mech.get_node("Pilot/CockpitLight").visible = false
	player.get_node("SelfLight").visible = false
	Global.SCENE = "TheShallows"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
