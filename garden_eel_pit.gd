extends CharacterBody2D
@export var anim_player: AnimationPlayer
@export var anim_player2: AnimationPlayer
@export var anim_player3: AnimationPlayer
@export var anim_player4: AnimationPlayer
@export var anim_player5: AnimationPlayer
@export var anim_player6: AnimationPlayer
@export var anim_player7: AnimationPlayer
@export var anim_player8: AnimationPlayer
@export var anim_player9: AnimationPlayer

@export var y_knockback = 25
@export var x_knockback = 130

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("Eel")
	anim_player2.play("Eel")
	anim_player3.play("Eel")
	anim_player4.play("Eel")
	anim_player5.play("Eel")
	anim_player6.play("Eel")
	anim_player7.play("Eel")
	anim_player8.play("Eel")
	anim_player9.play("Eel")
