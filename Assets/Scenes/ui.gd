extends CanvasLayer
@onready var botbar = $BottomBar
@onready var botbarcont = $BottomBarCont
@onready var topbar = $TopBar
@onready var timer = $Timer

var botbar_onscreen_pos = Vector2(960,1016)
var topbar_onscreen_pos = Vector2(960,96)

var botbar_offscreen_pos = Vector2(960,1130)
var topbar_offscreen_pos = Vector2(960,-106)

var delay = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.CONTROLSET == "kb":
		botbar.visible = true
		botbarcont.visible = false
	elif Global.CONTROLSET == "cont":
		botbar.visible = false
		botbarcont.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(Global):
		if Input.is_action_pressed("kb_or_controller") and delay == false:
			if Global.CONTROLSET == "cont":
				Global.CONTROLSET = "kb"
			elif Global.CONTROLSET == "kb":
				Global.CONTROLSET = "cont"
			
			if Global.CONTROLSET == "kb":
				botbar.visible = true
				botbarcont.visible = false
			elif Global.CONTROLSET == "cont":
				botbar.visible = false
				botbarcont.visible = true
				
			timer.start(1.0)
			delay = true
			
		if Global.MODE == "Mech":
			botbar.position.y = lerp(botbar.position.y, botbar_onscreen_pos.y, delta * 5)
			botbarcont.position.y = lerp(botbarcont.position.y, botbar_onscreen_pos.y, delta * 5)
			topbar.position.y = lerp(topbar.position.y, topbar_onscreen_pos.y, delta * 5)
		elif Global.MODE == "Nauto":
			botbar.position.y = lerp(botbar.position.y, botbar_offscreen_pos.y, delta * 5)
			botbarcont.position.y = lerp(botbarcont.position.y, botbar_offscreen_pos.y, delta * 5)
			topbar.position.y = lerp(topbar.position.y, topbar_offscreen_pos.y, delta * 5)

func switch_controls() -> void:
	if Global.CONTROLSET == "cont":
		Global.CONTROLSET = "kb"
	elif Global.CONTROLSET == "kb":
		Global.CONTROLSET = "cont"
	
func _on_timer_timeout() -> void:
	delay = false
