extends CharacterBody2D
@onready var anim_player = $AnimatedSprite2D
@onready var timer = $Timer

enum States {READY, MIMIC, IDLE, WALK, WALKDRILL}

var state: States = States.READY

func _ready() -> void:
	timer.start(2)

func _physics_process(delta: float) -> void:
	pass
	
func _on_timer_timeout() -> void:
	if state == States.READY:
		anim_player.play("Mimic")
		state = States.MIMIC
		timer.start(1)
	elif state == States.MIMIC:
		anim_player.play("Idle")
		state = States.IDLE
		timer.start(2)
	elif state == States.IDLE:
		anim_player.play("Walk")
		state = States.WALK
		timer.start(3)
	elif state == States.WALK:
		anim_player.play("WalkDrill")
		state = States.WALKDRILL
		timer.start(4)
