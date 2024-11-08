extends Node2D
@onready var background_music = $BGMusic
@onready var music_credit = $BGMusicCanvas/BGMusicCredit
@onready var timer = $Timer

var color = Color("FFFFFF")
var music_credit_text = "NOW PLAYING\n\"Shallows\" by Josh Thies"

var isFading = false

func _ready() -> void:
	background_music.play()
	music_credit.text = music_credit_text
	timer.start(4)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isFading == true:
		color.a -= 0.005
		music_credit.add_theme_color_override("default_color", color)
	if color.a == 0:
		isFading = false

func _on_timer_timeout() -> void:
	isFading = true
