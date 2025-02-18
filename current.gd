extends CharacterBody2D

var body_inside = false
@export var body : Node2D

func _physics_process(delta: float) -> void:
	print (name, ": ", body_inside)
	if body_inside:
		print (roundf(rotation_degrees))
		match roundf(rotation_degrees):
			90.0: 
				body.velocity.y += delta * -900
			135.0:
				body.velocity.y += delta * -636
				body.velocity.x += delta * 636
			180.0:
				body.velocity.x += delta * 900
			225.0:
				body.velocity.y += delta * 636
				body.velocity.x += delta * 636
			270.0:
				body.velocity.y += delta * 900
			315.0:
				body.velocity.y += delta * 636
				body.velocity.x += delta * -636
			360.0:
				body.velocity.x += delta * -900
			45.0:
				body.velocity.y += delta * -636
				body.velocity.x += delta * -636
				
	else:
		pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print ("body entered")
	if body.name == "Nauto":
		body_inside = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	print ("body exited")
	if body.name == "Nauto":
		body_inside = false
