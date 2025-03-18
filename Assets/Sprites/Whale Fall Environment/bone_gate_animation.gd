extends Node2D
@onready var animation_player = $Front/AnimationPlayer

func _ready():
	play_gate_animation()

func play_gate_animation():
	print("opening")
	animation_player.play("Gate_algae")
	
