extends CharacterBody2D

@export var body : Node2D
@export var body2 : Node2D
@export var push_strength = 300
@export var enabled_by_default: bool = true

var body_inside = false
var body2_inside = false

func _ready():
	if not enabled_by_default:
		disable_booster()

func _physics_process(delta: float) -> void:
	#print (name, ": ", body_inside)
	if body_inside:
		#print (roundf(rotation_degrees))
		match roundf(rotation_degrees):
			90.0: 
				body.velocity = Vector2(0, -push_strength)
	else:
		pass
	if body2_inside:
		#print (roundf(rotation_degrees))
		match roundf(rotation_degrees):
			90.0: 
				body2.velocity = Vector2(0, -push_strength)
	else:
		pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	#print ("body entered")
	if body.name == "Nauto":
		body_inside = true
	if body2.name == "Mech":
		body2_inside = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	#print ("body exited")
	if body.name == "Nauto":
		body_inside = false
	if body2.name == "Mech":
		body2_inside = false
		

func disable_booster():
	set_process(false)  # Disable physics processing
	set_physics_process(false)  # Disable physics processing
	visible = false  # Hide the booster
	print("Booster disabled")

func enable_booster():
	set_process(true)  # Enable physics processing
	set_physics_process(true)  # Enable physics processing
	visible = true  # Show the booster
	print("Booster enabled")
