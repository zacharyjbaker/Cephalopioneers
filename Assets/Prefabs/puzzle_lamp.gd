extends Area2D

@onready var PlayerCamera : Camera2D = get_node("../Nauto/NautoCamera")
@export var lamp: NodePath  # Assign the booster instance in the Inspector
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var Sprite1 = $Sprite2D
@onready var Plantlight = $BulbLight
@onready var Sprite2 = $E
var is_player_near = false
var is_active = false

func _process(_delta):
	if is_player_near and Input.is_action_just_pressed("interact") and not is_active:
		activate_lamp()

func activate_lamp():
	is_active = true
	# Play lamp animation (if any)
	animation_player.play("Collect")

func _on_area_entered(area):
	if area.is_in_group("player"):
		print("Player entered Lamp area")
		is_player_near = true
		if is_active == false:
			Sprite2.visible = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		print("Player exited Lamp area")
		is_player_near = false
		if is_active == false:
			Sprite2.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Sprite1.visible = false
	Sprite2.queue_free()
	Plantlight.visible = false
	if anim_name == "Collect":
		# Enable the lamp and activate the cauldron after the animation finishes
		if lamp:
			var lamp_node = get_node(lamp)
			if lamp_node is Node2D:
				# Increment the global last active cauldron index
				Global.last_active_cauldron += 1
				
				# Reset to 0 if all cauldrons have been activated
				if Global.last_active_cauldron >= PlayerCamera.Cauldrons.size():
					Global.last_active_cauldron = 0

				# Pan the camera to the activated cauldron
				PlayerCamera.cauldron_activated(Global.last_active_cauldron)
				
				# Enable the cauldron
				var cauldron_to_activate = PlayerCamera.Cauldrons[Global.last_active_cauldron]
				cauldron_to_activate.enable_cauldron()
			else:
				print("Assigned node is not a Node2D")
		else:
			print("Lamp not assigned")
