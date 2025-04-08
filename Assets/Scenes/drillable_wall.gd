extends TileMapLayer
@export var durability = 100
var drillable = false
@export var mech : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if drillable == true and Input.is_action_pressed("back_arm"):
		print ("Durability:", durability)
		mech.drill_particles.emitting = true
		if durability > 0:
			durability -= 1
		else:
			var all_tile_zero_cells = self.get_used_cells()
			for i in all_tile_zero_cells:
				clear()
			queue_free()
			drillable = false
			mech.drill_particles.emitting = false
	elif drillable == true and mech.drill_particles.emitting == true:
		mech.drill_particles.emitting = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "DrillArea":
		print ("Detecting drill")
		drillable = true
	if area.name == "Boulder":
		var all_tile_zero_cells = self.get_used_cells()
		for i in all_tile_zero_cells:
			clear()
		area.get_parent().queue_free()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.name == "DrillArea":
		print ("Not detecting drill")
		drillable = false
