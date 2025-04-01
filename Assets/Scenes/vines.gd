extends Sprite2D

@export var player: Node2D  # Assign the player node in the editor
@export var max_skew: float = 200.0  # Maximum skew effect when the player is close
@export var influence_radius: float = 100.0  # How close the player needs to be to trigger skew

var shader_material: ShaderMaterial

func _ready():
	shader_material = self.material as ShaderMaterial  # Adjust this path to match your node

func _process(delta):
	if player:
		var distance = global_position.distance_to(player.global_position)
		var effect = clamp(1.0 - (distance / influence_radius), 0.0, 1.0)
		material.set_shader_parameter("skew", effect * max_skew)
