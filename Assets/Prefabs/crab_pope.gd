extends CharacterBody2D
@onready var anim_player = $Sprite
@onready var timer = $Timer
@onready var temp_hit_box = $TempHitBox
@onready var hit_box = $HitBox
@onready var roarSFX = $RoarSFX
@onready var beamsSFX = $BeamsSFX
@onready var slamSFX = $SlamSFX
@onready var portalSFX = $PortalSFX
@onready var jumpSFX = $JumpSFX
@onready var magicSFX = $MagicSFX
@onready var shatterSFX = $ShatterSFX

@onready var skullslamVSFX = $SkullSlamVSFX
@onready var deathVSFX = $DeathVSFX
@onready var blastVSFX = $BlastVSFX
@onready var summonVSFX = $SummonVSFX
@onready var struggleVSFX = $StruggleVSFX

@onready var staff_light = $Sprite/StaffLight
@onready var death_fx = $Death
@onready var damage_fx = $Damage

@export var path1 : Node2D
@export var path2 : Node2D
@export var smash_path : Node2D
@export var crab_spawnpoints : Node
@export var blast_spawnpoints : Node
@export var player: Node2D = null
@export var max_durability = 50
@export var durability = max_durability
@export var health = 3
@export var mech : Node2D
@export var env_node : WorldEnvironment
@export var dg_manager : Node2D
var crab_minion = preload("res://Assets/Prefabs/lil_crab.tscn")
var eye_blast = preload("res://Assets/Prefabs/eye_blast.tscn")
var eel_blast = preload("res://Assets/Prefabs/eel_blast.tscn")

var rng = RandomNumberGenerator.new()

signal crab_light

enum States {IDLE, JUMP, SLAM, SKULL_SLAM, BLAST, EEL_BLAST, STRUGGLE, TELEPORT}

var state: States = States.IDLE

var extended_states = [States.SLAM, States.JUMP, States.SKULL_SLAM, States.STRUGGLE, States.TELEPORT]

var path_follow = null

#var test_moveset = [States.SKULL_SLAM, States.BLAST]
var moveset_one = [States.SLAM, States.BLAST, States.BLAST]
var moveset_two = [States.SLAM, States.EEL_BLAST]
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
var start_rot
var move_counter = 0

var drillable = false
var inAir = false
var isLightLerp = false
var teleporting = false
var isSkullSlamming = false
var isSkullSmashAnimPlaying = false
var isStruggling = false
var startOnFloor = false
var dead = false
var flipped = false
var resetOrder = false
var nextMoveset = false
var jumpDirDetermined = false
var cooldown = 2

func _ready() -> void:
	if is_instance_valid(Global):
		if path1:
			current_path = path1
			path_follow = path1.get_child(0)
		anim_player.play("Idle")
		print ("Idle")
		#Global.BOSS_FIGHT = false
		velocity.y = 400
		start_pos = global_position
		start_rot = global_rotation_degrees
		#var dg_manager = get_node("/root/Node2D/DialogueManager")
		dg_manager.crab_light.connect(light_lerp)
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	if is_instance_valid(Global):
		###print (position.y)
		
		if health == 0 and dead == false:
			dead = true
			Global.FREEZE = true
			death_fx.emitting = true
			anim_player.play("Struggle")
			deathVSFX.play()
			await get_tree().create_timer(1.3).timeout
			#self.visible = false
			Global.FREEZE = false
			#queue_free()
			env_node.fade_to_black()
			print ("King Crab Defeated")
			await get_tree().create_timer(1.5).timeout
			_load_credits()
		
		if dead == true:
			anim_player.play("Struggle")
			
		if isLightLerp:
			staff_light.energy = lerp(staff_light.energy, 0.8, 1 * delta)
			#print (cockpit_light.energy)
			staff_light.texture_scale = lerp(staff_light.texture_scale, 0.2, 1.4 * delta)
		
		if drillable == true and Input.is_action_pressed("back_arm"):
			print ("Durability:", durability)
			mech.drill_particles.emitting = true
			if durability > 0:
				durability -= 1
			else:
				#break_player.stream = break_sfx
				#break_player.play()
				#print(break_sfx)
				#queue_free()
				drillable = false
				mech.drill_particles.emitting = false
				print ("skull broken")
				shatterSFX.play()
				health -= 1
				damage_fx.emitting = true
				
		elif drillable == true and mech.drill_particles.emitting == true:
			mech.drill_particles.emitting = false
		
		if is_on_floor() and startOnFloor == false and Global.BOSS_FIGHT == true:
			print ("on floor")
			startOnFloor = true
			_fight()
			velocity.y = 0
			
		if startOnFloor:
			##print ("Current Anim: ", anim_player.get_animation())
			distance = global_position.x - player.global_position.x	
			##print ("distance:", distance)
			if !isStruggling:
				if sign(distance) > 0 and flipped:
					scale.x = -1 * abs(scale.x)
					#print ("flip_l")
					flipped = false
				elif sign(distance) < 0 and !flipped:
					scale.x = -1 * abs(scale.x)
					#print ("flip_r")
					flipped = true
				
			if state == States.BLAST:
				anim_player.play("Blast")
				blastVSFX.play()
				#magicSFX.play()
			elif state == States.EEL_BLAST:
				anim_player.play("ForwardBlast")
				summonVSFX.play()
				magicSFX.play()
				
			elif state == States.SLAM or state == States.SKULL_SLAM :
				##print ("SLAM TO JUMP")
				if inAir == true and resetOrder == true and is_on_floor():
					#print ("RESET")
					anim_player.play("Idle")
					state = States.IDLE
					inAir = false
					resetOrder = false
					jumpDirDetermined = false
					#path_end = path_follow.h_offset
					#var current_transform = global_transform
					#global_transform = current_transform
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
					##print ("SkullSmash")
					anim_player.play("Struggle")
					struggleVSFX.play()
					Global.SHAKE = true
					$ShakeTimer.start(0.7)
					slamSFX.play()
					state = States.IDLE
					isSkullSlamming = false
					isSkullSmashAnimPlaying = false
					hit_box.remove_from_group("mech_damage")
					hit_box.remove_from_group("damage")
					temp_hit_box.remove_from_group("mech_damage")
					temp_hit_box.remove_from_group("damage")
					_do_move()
				if state == States.SLAM or state == States.SKULL_SLAM and is_on_floor():
					anim_player.play("Slam")
					##print ("slam")
					##print (anim_player.frame)
				elif state == States.SKULL_SLAM:
					pass
			
			elif state == States.IDLE:
				#print ("Idling")
				anim_player.play("Idle")
				
			if !is_on_floor():
				#print ("descending")
				if resetOrder:
					velocity.y += delta * Global.GRAVITY 
					if prev_pos > position.y: # falling transition anim
						anim_player.play("Descend")
				elif inAir:
					##print ("Offset:", path_follow.h_offset)
			
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
						#print ("playing Jaws")
						anim_player.play("Jaws")
						isSkullSmashAnimPlaying = true
					#elif isSkullSmashAnimPlaying == false:
						#anim_player.play("Descend")
					
					anim_player.rotation_degrees = lerp(anim_player.rotation_degrees, 190.0, delta)
					path_follow.h_offset += 190 * delta
					var prev_pos = position.y
				
func _fight():
	if !teleporting:
		print ("Move Counter:", move_counter)
		#print ("Load next moveset")
		var last_move = current_move
		current_move = 0
		#moveset_num = rng.randi_range(0, 3)
		moveset_num = rng.randi_range(0, 1)
		move_counter += 1
		
		while moveset_num == last_move:
			moveset_num = rng.randi_range(0, 1)
		
		#if move_counter >= 3 and !flipped:
			#current_moveset = moveset_final
			#cooldown = 2
			#move_counter = 0
		#else:
		if !flipped and move_counter >= 2:
			#print ("Skullslam")
			current_moveset = moveset_final
			cooldown = 2
			move_counter = -1
		else:
			match moveset_num:
				0:
					print ("Slam and Blast")
					current_moveset = moveset_one
					cooldown = 1
				1:
					print ("Slam and Summon")
					current_moveset = moveset_two
					cooldown = 2
				2:
					print ("Slam and Blast")
					current_moveset = moveset_one
					cooldown = 1
				3:
					print ("Slam and Summon")
					current_moveset = moveset_two
					cooldown = 2
				_:
					pass
					
		_do_move()
	
func _do_move():
	print ("Performing Move")
	print ("teleporting?", teleporting)
	if !teleporting:
		print ("GO!")
		print (teleporting)
		if current_move <= len(current_moveset) - 1:
			state = current_moveset[current_move]
			current_move += 1
			print ("State: ", state)
			print ("MoveSet: ", current_moveset)
			print ("Move: ", current_move)
		else:
			await get_tree().create_timer(cooldown).timeout
			print ("Next Moveset")
			if state != States.STRUGGLE:
				hit_box.add_to_group("mech_damage")
				hit_box.add_to_group("damage")
			_fight()

func _on_sprite_animation_finished() -> void:
	if is_instance_valid(Global):
		#print ("anim finished")
		if Global.BOSS_FIGHT == true:
			print ("anim finished")
			if !extended_states.has(state):
				#print ("Extended State")
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
							blast.add_to_group("instanced")
							get_tree().root.add_child(blast)
						beamsSFX.play()
					States.EEL_BLAST:
						var eel_blast = eel_blast.instantiate()
						roarSFX.play()
						if flipped:
							eel_blast.velocity.x = 1
							eel_blast.global_position.x = global_position.x + 300
						else:
							eel_blast.velocity.x = -1
							eel_blast.global_position.x = global_position.x - 300
						#eel_blast.rotation_degrees = 90
						eel_blast.global_position.y = global_position.y + 130
						eel_blast.add_to_group("instanced")
						get_tree().root.add_child(eel_blast)
					_:
						pass
				
				state = States.IDLE
				anim_player.play("Idle")
				_do_move()
			else:
				if state == States.SLAM:
					#print ("Slam Begin")
					velocity.y -= 100
					inAir = true
					jumpSFX.play()
					#print ("Spawn crab minions")
					
					var spawn1 = rng.randi_range(0, 3)
					var crab_minion_spawn_1 = crab_minion.instantiate()
					crab_minion_spawn_1.global_position = crab_spawnpoints.get_child(spawn1).global_position
					crab_minion_spawn_1.aggro_range = 1000000
					crab_minion_spawn_1.player = player
					crab_minion_spawn_1.add_to_group("instanced")
					get_tree().root.add_child(crab_minion_spawn_1)
					
					var spawn2 = rng.randi_range(0, 3)
					while spawn2 == spawn1:
						spawn2 = rng.randi_range(0, 3)
						
					var crab_minion_spawn_2 = crab_minion.instantiate()
					crab_minion_spawn_2.global_position = crab_spawnpoints.get_child(spawn2).global_position
					crab_minion_spawn_2.aggro_range = 1000000
					crab_minion_spawn_2.player = player
					crab_minion_spawn_2.add_to_group("instanced")
					get_tree().root.add_child(crab_minion_spawn_2)
				elif state == States.SKULL_SLAM:
					#print ("Skull Slam Begin")

					velocity.y -= 70
					isSkullSlamming = true
					isStruggling = true
					var current_transform = global_transform
					if current_path == path1:
						skullslamVSFX.play()
						path1.remove_child(path_follow)
						smash_path.add_child(path_follow)
						path_follow.add_child(self)
						current_path = smash_path
						path_follow.h_offset = 0.0
					elif current_path == path2:
						skullslamVSFX.play()
						path2.remove_child(path_follow)
						smash_path.add_child(path_follow)
						path_follow.add_child(self)
						current_path = smash_path
						path_follow.h_offset = 0.0
					global_transform = current_transform
					temp_hit_box.add_to_group("mech_damage")
					temp_hit_box.add_to_group("damage")
					hit_box.remove_from_group("mech_damage")
					hit_box.remove_from_group("damage")
				elif state == States.STRUGGLE:
					anim_player.play("Struggle")
					drillable = true
					hit_box.remove_from_group("mech_damage")
					hit_box.remove_from_group("damage")
					temp_hit_box.remove_from_group("mech_damage")
					temp_hit_box.remove_from_group("damage")
					state = States.TELEPORT
				elif state == States.TELEPORT and !teleporting:
					print ("Teleport")
					anim_player.play("Teleport")
					portalSFX.play()
					drillable = false
					teleporting = true
					await get_tree().create_timer(2).timeout
					teleporting = false
					#global_position = start_pos
					isStruggling = false
					var current_transform = global_transform
					smash_path.remove_child(path_follow)
					path1.add_child(path_follow)
					path_follow.add_child(self)
					current_path = path1
					path_follow.h_offset = 0.0
					global_position.x = start_pos.x
					global_position.y = start_pos.y - 1000
					anim_player.rotation_degrees = 0
					global_rotation_degrees = start_rot
					global_scale = current_transform.get_scale()
					inAir = true
					resetOrder = true
					durability = max_durability
					print ("Return to normal moveset")
					state = States.IDLE
					anim_player.play("Idle")
					
					#await get_tree().create_timer(3).timeout
					_do_move()
			#if nextMoveset and !isStruggling and !teleporting:
				

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "DrillArea":
		print ("Detecting drill")
		drillable = true
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.name == "DrillArea":
		print ("Not detecting drill")
		drillable = false
		
func light_lerp() -> void:
	isLightLerp = true

func _on_shake_timer_timeout() -> void:
	Global.SHAKE = false

func _on_sprite_sprite_frames_changed() -> void:
	if anim_player.animation == "Blast":
		if anim_player.frame == 6:
			beamsSFX.play()
			
func _load_credits() -> void:
	await get_tree().process_frame
	var current_scene = get_parent().get_parent().get_parent()
	for item in get_tree().get_nodes_in_group("instanced"):
		item.queue_free()
	var new_scene = ResourceLoader.load("res://Assets/Scenes/Credits.tscn")
	get_tree().get_root().add_child(new_scene.instantiate())
	#await get_tree().process_frame
	#Global.FREEZE = true
	print ("queue_free")
	current_scene.queue_free()
