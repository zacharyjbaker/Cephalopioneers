extends Node
#var scene_load = preload("res://save.tscn").instantiate()

func save_game():
	var scene_root = get_node("/root/Node2D")
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene_root)
	ResourceSaver.save(packed_scene, "res://save.tscn")
	#scene_load = load("res://save.tscn")
	
func load_game():
	
	#scene_root.free()
	#get_tree().change_scene_to_file("res://save_transition.tscn")
	var old_scene = get_tree().root.get_child(0)
	#get_tree().paused = true
	#get_tree().root.add_child(scene_load)
	
	#await get_tree().create_timer(1).timeout
	await get_tree().process_frame
	for item in get_tree().get_nodes_in_group("instanced"):
		item.queue_free()
	get_tree().change_scene_to_file("res://save.tscn")
	#old_scene.free()
	#await get_tree().create_timer(0.5).timeout
	#print (get_tree().root.current_scene)
	#get_tree().reload_current_scene()
	
	
func _ready() -> void:
	if get_tree().paused == true:
		get_tree().paused = false
	save_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		print ("Game saved")
		save_game()
	if Input.is_action_just_pressed("load"):
		print ("Save loaded")
		load_game()
	

	
