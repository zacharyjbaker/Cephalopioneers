extends CharacterBody2D
@onready var anim_player = $Sprite
@onready var timer = $Timer

var rng = RandomNumberGenerator.new()

enum States {IDLE, JUMP, SLAM, BLAST, BLAST2, MISSLE, MISSLE2, STUNNED}

var state: States = States.IDLE

var extended_states = [States.SLAM, States.JUMP]

var moveset_one = [States.BLAST, States.SLAM, States.BLAST]
var moveset_two = [States.SLAM, States.BLAST, States.BLAST]
#var moveset_two = [States.MISSLE, States.MISSLE2, States.MISSLE]
var movesets = [moveset_one, moveset_two]
var moveset_num
var current_move
var current_moveset

var inAir = false

func _ready() -> void:
	anim_player.play("Idle")
	Global.BOSS_FIGHT = true
	_fight()
	
func _physics_process(delta: float) -> void:
	print ("Current Anim: ", anim_player.get_animation())
		
	move_and_slide()
	
	if state == States.BLAST:
		anim_player.play("Blast")
		
	elif state == States.SLAM:
		if inAir == true and is_on_floor():
			anim_player.play("Idle")
			state = States.IDLE
			inAir = false
			_do_move()
		else:
			anim_player.play("Slam")
				
	
	elif state == States.IDLE:
		anim_player.play("Idle")
		
	if !is_on_floor():
		velocity.y += delta * Global.GRAVITY 
		anim_player.play("InAir")
		
func _fight():
	current_move = 0
	moveset_num = rng.randi_range(0, 1)
	match moveset_num:
		0:
			current_moveset = moveset_one
		1:
			current_moveset = moveset_two
	_do_move()
	
func _do_move():
	if current_move <= len(current_moveset) - 1:
		state = current_moveset[current_move]
		current_move += 1
		print ("Move: ", state)
		print ("Num: ", current_move)
	#timer.start(3)

func _on_sprite_animation_finished() -> void:
	if Global.BOSS_FIGHT == true:
		if !extended_states.has(state):
			state = States.IDLE
			anim_player.play("Idle")
			_do_move()
		else:
			if state == States.SLAM:
				velocity.y -= 500
				inAir = true
