extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/TheShallows.tscn")



func _on_credits_pressed() -> void:
	pass # Replace with function body.




func _on_quit_pressed() -> void:
	get_tree().quit()
