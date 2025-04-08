extends AnimatedSprite2D
@export var health_id = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(Global):
		if Global.MODE == "Mech":
			if Global.MECH_HEALTH >= health_id:	
				self.visible = true
				self.play("Armored")
			elif Global.HEALTH >= health_id:	
				self.visible = true
				self.play("Unarmored")
			else:
				self.visible = false
		else:
			if Global.HEALTH >= health_id:	
				self.play("Unarmored")
				self.visible = true
			else:
				self.visible = false
