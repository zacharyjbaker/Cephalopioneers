extends WorldEnvironment
@onready var timer = $Timer
var default_intensity = 0.06
var default_color = load("res://Assets/Prefabs/default_glow.tres")
var damage_color =  load("res://Assets/Prefabs/damage_glow.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if environment:
		print ("env valid")
	environment.glow_intensity = default_intensity
	environment.adjustment_color_correction.gradient = default_color

# Called every frame. 'delta'a is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if environment.glow_intensity > default_intensity:
		environment.glow_intensity -= 0.01
	if environment.adjustment_saturation > 1:
		environment.adjustment_saturation -= 0.25
	
func set_glow(intensity: float) -> void:
	environment.glow_intensity = intensity
	environment.adjustment_color_correction.gradient = damage_color
	environment.adjustment_saturation = 3
	timer.start(.3)
	#print (environment.adjustment_color_correction.gradient)

func _on_timer_timeout() -> void:
	environment.adjustment_color_correction.gradient = default_color
