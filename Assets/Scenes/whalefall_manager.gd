extends Node2D

@export var mech : Node2D
@export var player : Node2D
@export var env_node : WorldEnvironment
@export var dialogue_manager : Node2D
@export var save_load: Node2D

func _ready() -> void:
	save_load.save_game()
	mech.get_node("Pilot/CockpitLight").visible = true
	player.get_node("SelfLight").visible = true
	dialogue_manager.get_node("DialogueCanvas").visible = false
	print ("readying")
	env_node.fade_in()
	if Global.BOSS_FIGHT == false:
		Global.DIALOGUE_INSTANCE = 3
		Global.SHAKE = false
		player.get_node("Nauto").play("Charge")
		await get_tree().create_timer(5).timeout
		player.get_node("Nauto").play("Idle")
		Global.SCENE = "WhalefallSettlement"
		dialogue_manager.get_node("DialogueCanvas").visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
