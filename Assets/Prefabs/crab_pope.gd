extends CharacterBody2D
@onready var anim_player = $Sprite
@onready var timer = $Timer
@export var path : Node2D
@export var spawnpoints : Node
@export var player: Node2D = null
var crab_minion = preload("res://Assets/Prefabs/lil_crab.tscn")
var eye_blast = preload("res://Assets/Prefabs/eye_blast.tscn")

var rng = RandomNumberGenerator.new()

enum States {IDLE, JUMP, SLAM, BLAST, BLAST2, MISSLE, MISSLE2, STUNNED}

var state: States = States.IDLE

var extended_states = [States.SLAM, States.JUMP]

var path_follow = null

var moveset_one = [States.BLAST, States.SLAM, States.BLAST]
var moveset_two = [States.SLAM, States.BLAST, States.BLAST]
#var moveset_two = [States.MISSLE, States.MISSLE2, States.MISSLE]
var movesets = [moveset_one, moveset_two]
var moveset_num
var current_move
var current_moveset
var distance

var inAir = false
var startOnFloor = false
var flipped = false

func _ready() -> void:
	if path:
		path_follow = path.get_child(0)
	anim_player.play("Idle")
	Global.BOSS_FIGHT = true
	velocity.y = 100
	
func _physics_process(delta: float) -> void:
	#print (position.y)
	move_and_slide()
	if is_on_floor() and startOnFloor == false:
		print ("on floor")
		startOnFloor = true
		_fight()
		velocity.y = 0
		
	if startOnFloor:
		#print ("Current Anim: ", anim_player.get_animation())
		distance = global_position.x - player.global_position.x	
		#print ("distance:", distance)
		if sign(distance) > 0 and flipped:
			scale.x = abs(scale.x)
			print ("flip_l")
			flipped = false
		elif sign(distance) < 0 and !flipped:
			scale.x = -1 * abs(scale.x)
			print ("flip_r")
			flipped = true
			
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
			path_follow.h_offset += 190 * delta
			
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

func _on_sprite_animation_finished() -> void:
	if Global.BOSS_FIGHT == true:
		if !extended_states.has(state):
			
			match state:
				States.BLAST:
					var blast_1 = eye_blast.instantiate()
					blast_1.global_position = global_position
					if sign(distance) > 0:
						blast_1.velocity.x = -1
					elif sign(distance) < 0:
						blast_1.velocity.x = 1
					get_tree().root.add_child(blast_1)
				_:
					pass
			
			state = States.IDLE
			anim_player.play("Idle")
			_do_move()
		else:
			if state == States.SLAM:
				velocity.y -= 100
				inAir = true
				print ("Spawn crab minions")
				
				var spawn1 = rng.randi_range(0, 3)
				var crab_minion_spawn_1 = crab_minion.instantiate()
				crab_minion_spawn_1.global_position = spawnpoints.get_child(spawn1).global_position
				crab_minion_spawn_1.aggro_range = 1000000
				get_tree().root.add_child(crab_minion_spawn_1)
				
				var spawn2 = rng.randi_range(0, 3)
				while spawn2 == spawn1:
					spawn2 = rng.randi_range(0, 3)
					
				var crab_minion_spawn_2 = crab_minion.instantiate()
				crab_minion_spawn_2.global_position = spawnpoints.get_child(spawn2).global_position
				crab_minion_spawn_2.aggro_range = 1000000
				get_tree().root.add_child(crab_minion_spawn_2)
