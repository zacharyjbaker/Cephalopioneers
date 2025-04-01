extends Area2D

@export var new_color: Color = Color(1, 0, 0, 1) # Default: Red
@onready var animation_player = $Sprite2D/AnimationPlayer
var has_been_triggered = false  # Flag to prevent re-triggering

func _on_area_entered(area):
	if has_been_triggered:
		return  # Exit if already triggered

	if area.is_in_group("player"):
		has_been_triggered = true  # Mark as triggered
		animation_player.play("ChestOpen")

		var player = area.get_parent() # Get the CharacterBody2D
		if player:
			var sprite = player.find_child("Nauto", true, false)
			if sprite and sprite.material:
				sprite.material.set_shader_parameter("color_tint", new_color)
