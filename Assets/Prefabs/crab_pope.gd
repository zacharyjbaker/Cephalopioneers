extends CharacterBody2D
@onready var anim_player = $Sprite

func _ready() -> void:
	anim_player.play("Idle")
	
func _physics_process(delta: float) -> void:
	pass
