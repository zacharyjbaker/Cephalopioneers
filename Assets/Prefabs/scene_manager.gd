extends Node2D

func _ready() -> void:
	pass
	'''
	if is_instance_valid(Global):
		var scene_groups = get_tree().current_scene.get_groups()
		print ("Current Scene:", get_tree().current_scene)
		print ("Scene: ", scene_groups[0])
		match scene_groups[0]:
			"TheShallows":
				Global.SCENE = "TheShallows"
			"WhalefallSettlement":
				Global.SCENE = "WhalefallSettlement"
			_:
				pass
	'''

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
