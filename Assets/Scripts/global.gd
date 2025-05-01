extends Node

var SCENE = "TheShallows"
var GRAVITY = 400
var WALK_SPEED = 400
var HEALTH = 5
var MECH_HEALTH = 5
var MODE = "Nauto"
var INTERACTABLE = false
var FREEZE = false
var SHAKE = false
var SHAKE_AMT = 0
var EEL_CUTSCENE = false
var CHASE = false
var BOSS_FIGHT = false
var DAMAGED = false
var START = true
var last_active_cauldron: int = -1
var DIALOGUE_INSTANCE = 1
var SAVENUM = 0
var CONTROLSET = "kb"

func reset_globals():
	HEALTH = 5
	MECH_HEALTH = 5
	#MODE = "Nauto"
	INTERACTABLE = false
	FREEZE = false
	SHAKE = false
	SHAKE_AMT = 0
	EEL_CUTSCENE = false
	BOSS_FIGHT = false
	DAMAGED = false
	START = false
	
func reset_globals_bossfight():
	HEALTH = 5
	MECH_HEALTH = 5
	#MODE = "Nauto"
	INTERACTABLE = false
	FREEZE = false
	SHAKE = false
	SHAKE_AMT = 0
	EEL_CUTSCENE = false
	DAMAGED = false
	START = false
	BOSS_FIGHT = false
	
func set_dialogue(dialogue_instance: int):
	var DIALOGUE_INSTANCE = dialogue_instance
	
