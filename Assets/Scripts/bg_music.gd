extends Node2D
@onready var background_music = $BGMusic
@onready var music_credit = $BGMusicCanvas/BGMusicCredit
@onready var timer = $Timer

var color = Color("FFFFFF")
var song_list = ["res://Assets/Sound/Music/Cargo.mp3", "res://Assets/Sound/Music/TheLeviathan.wav", "res://Assets/Sound/Rumble.mp3", "res://Assets/Sound/Music/Whale.mp3"]
var credit_list = ["NOW PLAYING\n\"The Shallows\" by Josh Thies", "NOW PLAYING\n\"The Leviathan\" by Zachary Baker", "", "NOW PLAYING\n\"The Whalefall\" by Josh Thies"]

var isFading = false

func _ready() -> void:
	if is_instance_valid(Global):
		match Global.SCENE:
			"TheShallows":
				change_music(0)
				var eel_script = get_node("/root/Node2D/LeviathanEel")
				eel_script.bgmusic_chase.connect(change_music.bind(1))
				eel_script.bgmusic_stop.connect(change_music.bind(-1))
			"WhalefallSettlement":
				change_music(3)
			_:
				pass
			
		
		var dialogue_script = get_node("/root/Node2D/DialogueManager")
		var nauto_script = get_node("/root/Node2D/Nauto")
		
		dialogue_script.bgmusic_stop.connect(change_music.bind(-1))
		dialogue_script.bgmusic_rumble.connect(change_music.bind(2))
		nauto_script.bgmusic_rumble.connect(change_music.bind(2))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isFading == true:
		color.a -= 0.002
		music_credit.add_theme_color_override("default_color", color)
	if color.a == 0:
		isFading = false

func _on_timer_timeout() -> void:
	pass
	
func change_music(song_index: int) -> void:
	if song_index == -1:
		background_music.stop()
		return
	isFading = false
	color.a = 1
	#timer.start(4)
	var song = load(song_list[song_index])
	background_music.stream = song
	background_music.play()
	music_credit.text = credit_list[song_index]
	print (song)
	isFading = true
	
	
