extends CanvasLayer
@onready var botbar = $BottomBar
@onready var topbar = $TopBar

var botbar_onscreen_pos = Vector2(960,1016)
var topbar_onscreen_pos = Vector2(960,96)

var botbar_offscreen_pos = Vector2(960,1130)
var topbar_offscreen_pos = Vector2(960,-106)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(Global):
		if Global.MODE == "Mech":
			botbar.position.y = lerp(botbar.position.y, botbar_onscreen_pos.y, delta * 5)
			topbar.position.y = lerp(topbar.position.y, topbar_onscreen_pos.y, delta * 5)
		elif Global.MODE == "Nauto":
			botbar.position.y = lerp(botbar.position.y, botbar_offscreen_pos.y, delta * 5)
			topbar.position.y = lerp(topbar.position.y, topbar_offscreen_pos.y, delta * 5)
