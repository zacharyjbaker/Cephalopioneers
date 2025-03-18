extends Node2D

@onready var animation_player1 = $CauldronSpriteActivate/AnimationPlayer
@onready var animation_player2 = $CauldronSpriteLoop/AnimationPlayer
@onready var Sprite2 = $CauldronSpriteLoop
@onready var CauldronLight = $CauldronLight

@export var cauldron_id: int = -1

func _ready():
	CauldronLight.visible = false

func _physics_process(delta: float) -> void:
		pass

func enable_cauldron():
	animation_player1.play("Charge")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Charge":
		Sprite2.visible = true
		CauldronLight.visible = true
		animation_player2.play("ActiveLoop")
		
