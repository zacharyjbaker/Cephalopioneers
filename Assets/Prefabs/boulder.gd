extends RigidBody2D

@export var detection_range: float = 100.0
@export var roll_force: Vector2 = Vector2(-150.0, 0.0)
@export var friction_reduction: float = 0.1
@export var FallTimer: Timer

var player: Node2D = null
var has_fallen := false
var has_landed := false

func _ready():
	freeze = true  
	find_player()

	# Adjust physics material for rolling
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = friction_reduction
	physics_material_override.bounce = 0.1  

	linear_damp = 0  
	angular_damp = 0  

func _process(_delta):
	if player and not has_fallen:
		var distance = global_position.distance_to(player.global_position)
		if distance < detection_range:
			freeze = false  
			has_fallen = true 
			if has_fallen: 
				FallTimer.start() 


func _on_timer_timeout() -> void:
	has_landed = true
	if has_landed:
		add_constant_force(roll_force)

func find_player():
	var scene = get_tree().current_scene
	if scene:
		player = scene.get_node_or_null("Nauto")
