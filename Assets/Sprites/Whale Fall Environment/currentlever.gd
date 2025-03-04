extends Area2D

@export var booster: NodePath  # Assign the booster instance in the Inspector
var is_player_near = false
var is_pulled = false

func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact") and not is_pulled:
		pull_lever()

func pull_lever():
	is_pulled = true
	# Play lever animation (if any)
	$AnimationPlayer.play("Pull")
	
	# Enable the booster if it's disabled
	if booster:
		var booster_node = get_node(booster)
		if booster_node is CharacterBody2D:
			if not booster_node.enabled_by_default:  # Check if the booster is disabled by default
				booster_node.enable_booster()  # Enable the booster
				print("Booster enabled by lever")
			else:
				booster_node.disable_booster()
				print("Booster disabled by lever")
		else:
			print("Assigned node is not a CharacterBody2D")
	else:
		print("Booster not assigned")

func _on_area_entered(area):
	if area.is_in_group("player"):
		print("Player entered lever area")
		is_player_near = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		print("Player exited lever area")
		is_player_near = false
