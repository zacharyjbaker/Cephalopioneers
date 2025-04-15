extends Node
#var scene_load = preload("res://save.tscn").instantiate()
@export var save_text : CanvasLayer

func save_game():
	print ("Saving: ", str("res://Saves/save", str(Global.SAVENUM), ".tscn"))
	#if ResourceLoader.exists("res://Saves/save.tscn"):
		#var dir = DirAccess.open("res://Saves")
		#dir.remove("save.tscn")
	var scene_root = self
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene_root)
	ResourceSaver.save(packed_scene, str("res://Saves/save", str(Global.SAVENUM), ".tscn"))
	save_text.visible = true
	await get_tree().create_timer(2.5).timeout
	save_text.visible = false
	Global.START = false
	#scene_load = load("res://save.tscn")
	
func load_game():
	
	#scene_root.free()
	#get_tree().change_scene_to_file("res://save_transition.tscn")
	#var old_scene = get_tree().root.get_child(0)
	
	#get_tree().paused = true
	#get_tree().root.add_child(scene_load)
	
	#await get_tree().create_timer(1).timeout
	if ResourceLoader.exists(str("res://Saves/save", str(Global.SAVENUM), ".tscn")):
		await get_tree().process_frame
		for item in get_tree().get_nodes_in_group("instanced"):
			item.queue_free()
		
		var new_scene = ResourceLoader.load(str("res://Saves/save", str(Global.SAVENUM), ".tscn"))
		print ("Loading: ", str("res://Saves/save", str(Global.SAVENUM), ".tscn"))
		get_tree().get_root().add_child(new_scene.instantiate())
		#await get_tree().process_frame
		#Global.FREEZE = true
		Global.SAVENUM += 1
		if Global.SAVENUM == 5:
			Global.SAVENUM = 0
		self.queue_free()
	
	
	#var scene_load = load("res://save.tscn")
	#var current_level = scene_load.instantiate()
	#add_child(current_level)	
	#get_tree().change_scene_to_packed(scene_load)
	#old_scene.queue_free()
	#old_scene.free()
	#await get_tree().create_timer(0.5).timeout
	#print (get_tree().root.current_scene)
	#get_tree().reload_current_scene()
	
	
func _ready() -> void:
	if get_tree().paused == true:
		get_tree().paused = false
	#save_game()
	#Global.FREEZE = false
	#Global.MODE = "Nauto"
	if self.name != "Node2D":
		self.name = "Node2D"
	get_tree().set_current_scene(get_tree().get_root().get_child(0))
	#var reload = get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		print ("Game saved")
		save_game()
	if Input.is_action_just_pressed("load"):
		print ("Save loaded")
		load_game()
		
	

	
