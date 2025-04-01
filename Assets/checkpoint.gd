extends Node2D

func save_game():
	print ("game saved")
	var scene_root = get_node("/root/Node2D")
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene_root)
	ResourceSaver.save(packed_scene, "res://save.tscn")
	#scene_load = load("res://save.tscn")



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Nauto" or body.name == "Mech":
		save_game()
