extends Control

func _on_back_pressed() -> void:
	await get_tree().process_frame
	var current_scene = self
	for item in get_tree().get_nodes_in_group("instanced"):
		item.queue_free()
	var new_scene = ResourceLoader.load("res://Assets/Scenes/title.tscn")
	get_tree().get_root().add_child(new_scene.instantiate())
	#await get_tree().process_frame
	#Global.FREEZE = true
	print ("queue_free")
	current_scene.queue_free()
