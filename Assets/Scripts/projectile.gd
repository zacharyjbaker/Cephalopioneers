extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var invert_sprite = $AnimationPlayer
@onready var direction = 0
@export var speed = 600

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print ("Proj Instantiated")
	sprite.play("Flicker") # Replace with function body.
	#invert_sprite.play("default")
	velocity.x = velocity.x * speed
	print (velocity.x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_slide() 
	if velocity.x > 1:
		scale.y = abs(scale.y)
		rotation_degrees = 0

	elif velocity.x < -1:
		scale.y = -1 * abs(scale.y)
		rotation_degrees = 180
	#print("Laser:", velocity.x)
