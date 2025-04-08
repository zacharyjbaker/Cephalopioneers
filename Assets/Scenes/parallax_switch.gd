extends ParallaxBackground

# Reference to the player node
@export var player: NodePath
@onready var BGTimer = $Timer
@onready var player_node: CharacterBody2D = get_node(player)
@onready var transition_node: CanvasLayer = get_node("../Transition")

# Reference to the parallax background node to hide
@export var parallax_to_hide: NodePath
@onready var parallax_node: ParallaxBackground = get_node(parallax_to_hide)

# X value at which the parallax background should become invisible
@export var hide_at_x: float = 22100

# Track the player's last position
var last_player_x = 0.0
var waiting_to_hide = false
var waiting_to_show = false

func _ready() -> void:
	if not player_node or not parallax_node:
		print("Player or parallax node not assigned!")
		set_process(false)
	
	last_player_x = player_node.global_position.x

func _process(delta: float) -> void:
	var current_x = player_node.global_position.x
	var current_y = player_node.global_position.y

	# Crossing from left to right
	if last_player_x < hide_at_x and current_x >= hide_at_x and not waiting_to_hide and current_y > 700 :
		transition_node.startTransition()
		BGTimer.start()
		waiting_to_hide = true
		waiting_to_show = false

	# Crossing from right to left
	if last_player_x > hide_at_x and current_x <= hide_at_x and not waiting_to_show and current_y > 700:
		transition_node.startTransition()
		BGTimer.start()
		waiting_to_show = true
		waiting_to_hide = false

	last_player_x = current_x

func _on_timer_timeout() -> void:
	if waiting_to_hide:
		parallax_node.visible = false
		waiting_to_hide = false
	elif waiting_to_show:
		parallax_node.visible = true
		waiting_to_show = false
