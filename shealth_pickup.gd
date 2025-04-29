extends CharacterBody2D
@onready var sprite = $Sprite
@export var HP_layer : CanvasLayer
var HP = null

func _ready() -> void:
	sprite.play("Idle")
	HP = HP_layer.get_node("HP").get_children()
	print ("HP Nodes:", HP)

func _physics_process(delta: float) -> void:
	pass


func _on_collider_body_entered(body: Node2D) -> void:
	if body.name == "Nauto" or body.name == "Mech":
		if Global.HEALTH < 5:
			Global.HEALTH = 5
			for i in HP:
				print (i.name)
				if i.visible == false:
					i.visible = true
				
