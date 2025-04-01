extends Area2D

@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var Sprite2 = $E
var is_player_near = false
var is_pulled = false

func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact") and not is_pulled and all_cauldrons_activated():
		open_cathedral()

func open_cathedral():
	is_pulled = true
	# Play lever animation (if any)
	animation_player.play("CathedralDoor")

func _on_area_entered(area):
	if area.is_in_group("player"):
		print("Player entered lever area")
		is_player_near = true
		if all_cauldrons_activated():
			Sprite2.visible = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		print("Player exited lever area")
		is_player_near = false
		Sprite2.visible = false

func all_cauldrons_activated() -> bool:
	# Assuming you have 4 cauldrons and Global.last_activated_cauldron_index starts at -1
	# All cauldrons are activated if the last activated index is 3 (0-based index for 4 cauldrons)
	return Global.last_active_cauldron >= 3



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "CathedralDoor":  # Match the exact animation name
		get_tree().change_scene_to_file("res://Assets/Scenes/bossfight.tscn")
