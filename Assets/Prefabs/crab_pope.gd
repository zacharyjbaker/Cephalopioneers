extends CharacterBody2D
@onready var anim_player = $Sprite
@onready var timer = $Timer
@export var path1 : Node2D
@export var path2 : Node2D
@export var smash_path : Node2D
@export var crab_spawnpoints : Node
@export var blast_spawnpoints : Node
@export var player: Node2D = null
var crab_minion = preload("res://Assets/Prefabs/lil_crab.tscn")
var eye_blast = preload("res://Assets/Prefabs/eye_blast.tscn")
var eel_blast = preload("res://Assets/Prefabs/eel_blast.tscn")

var rng = RandomNumberGenerator.new()

enum States {IDLE, JUMP, SLAM, SKULL_SLAM, BLAST, EEL_BLAST, STRUGGLE, TELEPORT}

var state: States = States.IDLE

var extended_states = [States.SLAM, States.JUMP, States.SKULL_SLAM, States.STRUGGLE, States.TELEPORT]

var path_follow = null

#var test_moveset = [States.SKULL_SLAM, States.BLAST]
var moveset_one = [States.SLAM, States.BLAST, States.BLAST]
var moveset_two= [States.SLAM, States.EEL_BLAST]
#var moveset_three = [States.BLAST, States.BLAST]
var moveset_final = [States.SKULL_SLAM, States.STRUGGLE] #States.TELEPORT]
#var moveset_final = [States.SKULL_SLAM, States.STRUGGLE, States.TELEPORT]
#var moveset_two = [States.MISSLE, States.MISSLE2, States.MISSLE]
var movesets = [moveset_one, moveset_two]
var moveset_num
var current_move
var current_moveset
var distance
var offset
var path_end
var current_path
var prev_pos = 0
var start_pos
var move_counter = 0

var inAir = false
var isSkullSlamming = false
var isSkullSmashAnimPlaying = false
var isStruggling = false
var startOnFloor = false
var flipped = false
var resetOrder = false
var nextMoveset = false
var jumpDirDetermined = false
var cooldown = 2

func _ready() -> void:
	if path1:
		current_path = path1
		path_follow = path1.get_child(0)
	anim_player.play("Idle")
	Global.BOSS_FIGHT = true
	velocity.y = 100
	start_pos = global_transform
	
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
		if !isStruggling:
			if sign(distance) > 0 and flipped:
				scale.x = -1 * abs(scale.x)
				print ("flip_l")
				flipped = false
			elif sign(distance) < 0 and !flipped:
				scale.x = -1 * abs(scale.x)
				print ("flip_r")
				flipped = true
			
		if state == States.BLAST:
			anim_player.play("Blast")
		elif state == States.EEL_BLAST:
			anim_player.play("ForwardBlast")
			
		elif state == States.SLAM or state == States.SKULL_SLAM :
			#print ("SLAM TO JUMP")
			if inAir == true and resetOrder == true and is_on_floor():
				anim_player.play("Idle")
				state = States.IDLE
				inAir = false
				resetOrder = false
				jumpDirDetermined = false
				#path_end = path_follow.h_offset
				var current_transform = global_transform
				global_transform = current_transform
				_do_move()
			elif inAir == true and is_on_floor():
				anim_player.play("Idle")
				state = States.IDLE
				inAir = false
				jumpDirDetermined = false
				#path_end = path_follow.h_offset
				var current_transform = global_transform
				if current_path == path1:
					path1.remove_child(path_follow)
					path2.add_child(path_follow)
					path_follow.add_child(self)
					current_path = path2
					path_follow.h_offset = 0.0
				elif current_path == path2:
					path2.remove_child(path_follow)
					path1.add_child(path_follow)
					path_follow.add_child(self)
					current_path = path1
					path_follow.h_offset = 0.0
				global_transform = current_transform
				_do_move()
			elif isSkullSlamming == true and is_on_floor():
				#print ("SkullSmash")
				anim_player.play("Struggle")
				state = States.IDLE
				isSkullSlamming = false
				isSkullSmashAnimPlaying = false
				_do_move()
			if state == States.SLAM or state == States.SKULL_SLAM and is_on_floor():
				anim_player.play("Slam")
				#print ("slam")
				#print (anim_player.frame)
			elif state == States.SKULL_SLAM:
				pass
		
		elif state == States.IDLE:
			anim_player.play("Idle")
			
		if !is_on_floor():
			if inAir:
				#print ("Offset:", path_follow.h_offset)
		
				velocity.y += delta * Global.GRAVITY 
				if prev_pos > position.y: # falling transition anim
					anim_player.play("Descend")
				elif prev_pos < position.y:  # ascending transition anim
					anim_player.play("InAir")
		
				path_follow.h_offset += 190 * delta
				var prev_pos = position.y
				
			elif isSkullSlamming:
				
				velocity.y += delta * Global.GRAVITY
				if isSkullSmashAnimPlaying == false:
					print ("playing Jaws")
					anim_player.play("Jaws")
					isSkullSmashAnimPlaying = true
				#elif isSkullSmashAnimPlaying == false:
					#anim_player.play("Descend")
				
				anim_player.rotation_degrees = lerp(anim_player.rotation_degrees, 190.0, delta)
				path_follow.h_offset += 190 * delta
				var prev_pos = position.y
			
func _fight():
	print ("Load next moveset")
	var last_move = current_move
	current_move = 0
	#moveset_num = rng.randi_range(0, 3)
	moveset_num = rng.randi_range(0, 2)
	move_counter += 1
	
	if moveset_num == last_move:
		moveset_num += 1
	
	#if move_counter >= 3 and !flipped:
		#current_moveset = moveset_final
		#cooldown = 2
		#move_counter = 0
	#else:
	match moveset_num:
		0:
			if !flipped:
				print ("Skullslam")
				current_moveset = moveset_final
				cooldown = 2
			else:
				print ("Slam and Blast")
				current_moveset = moveset_one
				cooldown = 1
		1:
			print ("Slam and Summon")
			current_moveset = moveset_two
			cooldown = 3
		2:
			if !flipped:
				print ("Skullslam")
				current_moveset = moveset_final
				cooldown = 2
			else:
				moveset_num = rng.randi_range(0, 1)
				match moveset_num:
					0:
						print ("Slam and Blast_2")
						current_moveset = moveset_one
						cooldown = 1
					1:
						("Slam and Summon_2")
						current_moveset = moveset_two
						cooldown = 3
		_:
			moveset_num = rng.randi_range(0, 1)
			match moveset_num:
				0:
					print ("Slam and Blast_2")
					current_moveset = moveset_one
					cooldown = 1
				1:
					("Slam and Summon_2")
					current_moveset = moveset_two
					cooldown = 3
				
	_do_move()
	
func _do_move():
	print ("Performing Move")
	if current_move <= len(current_moveset) - 1:
		state = current_moveset[current_move]
		current_move += 1
		print ("State: ", state)
		print ("MoveSet: ", current_moveset)
		print ("Move: ", current_move)
	else:
		nextMoveset = true

func _on_sprite_animation_finished() -> void:
	print ("anim finished")
	if Global.BOSS_FIGHT == true:
		if !extended_states.has(state):
			print ("Extended State")
			match state:
				States.BLAST:
					'''
					var blast_1 = eye_blast.instantiate()
					if sign(distance) > 0:
						blast_1.velocity.x = -1
						blast_1.global_position = global_position - Vector2(250, 0)
					elif sign(distance) < 0:
						blast_1.velocity.x = 1
						blast_1.global_position = global_position + Vector2(250, 0)
					get_tree().root.add_child(blast_1)
					'''
					var set_num = rng.randi_range(0, 1)
					var spawnset = blast_spawnpoints.get_child(set_num)
					for waypoint in spawnset.get_children():
						var blast = eye_blast.instantiate()
						blast.velocity.y = 1
						blast.rotation_degrees = 90
						blast.global_position = waypoint.global_position
						get_tree().root.add_child(blast)
				States.EEL_BLAST:
					var eel_blast = eel_blast.instantiate()
					if flipped:
						eel_blast.velocity.x = 1
						eel_blast.global_position.x = global_position.x + 400
					else:
						eel_blast.velocity.x = -1
						eel_blast.global_position.x = global_position.x - 400
					#eel_blast.rotation_degrees = 90
					eel_blast.global_position.y = global_position.y + 130
					get_tree().root.add_child(eel_blast)
				_:
					pass
			
			state = States.IDLE
			anim_player.play("Idle")
			_do_move()
		else:
			if state == States.SLAM:
				print ("Slam Begin")
				velocity.y -= 100
				inAir = true
				print ("Spawn crab minions")
				
				var spawn1 = rng.randi_range(0, 3)
				var crab_minion_spawn_1 = crab_minion.instantiate()
				crab_minion_spawn_1.global_position = crab_spawnpoints.get_child(spawn1).global_position
				crab_minion_spawn_1.aggro_range = 1000000
				get_tree().root.add_child(crab_minion_spawn_1)
				
				var spawn2 = rng.randi_range(0, 3)
				while spawn2 == spawn1:
					spawn2 = rng.randi_range(0, 3)
					
				var crab_minion_spawn_2 = crab_minion.instantiate()
				crab_minion_spawn_2.global_position = crab_spawnpoints.get_child(spawn2).global_position
				crab_minion_spawn_2.aggro_range = 1000000
				get_tree().root.add_child(crab_minion_spawn_2)
			elif state == States.SKULL_SLAM:
				print ("Skull Slam Begin")
				velocity.y -= 70
				isSkullSlamming = true
				isStruggling = true
				var current_transform = global_transform
				if current_path == path1:
					path1.remove_child(path_follow)
					smash_path.add_child(path_follow)
					path_follow.add_child(self)
					current_path = smash_path
					path_follow.h_offset = 0.0
				elif current_path == path2:
					path2.remove_child(path_follow)
					smash_path.add_child(path_follow)
					path_follow.add_child(self)
					current_path = smash_path
					path_follow.h_offset = 0.0
				global_transform = current_transform
			elif state == States.STRUGGLE:
				anim_player.play("Struggle")
				await get_tree().create_timer(1).timeout
				anim_player.play("Teleport")
				state = States.TELEPORT
			elif state == States.TELEPORT:
				#global_position = start_pos
				isStruggling = false
				#var current_transform = global_transform
				smash_path.remove_child(path_follow)
				path1.add_child(path_follow)
				path_follow.add_child(self)
				current_path = path1
				path_follow.h_offset = 0.0
				global_transform = start_pos
				inAir = true
				resetOrder = true
				print ("Return to normal moveset")
				await get_tree().create_timer(1).timeout
				_do_move()
		if nextMoveset:
			print ("Next Moveset")
			nextMoveset = false
			await get_tree().create_timer(cooldown).timeout
			_fight()
	
