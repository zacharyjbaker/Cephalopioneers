extends Node2D
@onready var background_music = $BGMusic
@onready var music_credit = $BGMusicCanvas/BGMusicCredit
@onready var timer = $Timer

@export var preset_volume = -0.5

var color = Color("FFFFFF")
var song_list = ["res://Assets/Sound/Music/Cargo.mp3", "res://Assets/Sound/Music/TheLeviathan.wav", "res://Assets/Sound/Rumble.mp3", "res://Assets/Sound/Music/Whale.mp3", "res://Assets/Sound/Music/BossFight.mp3"]
var credit_list = ["NOW PLAYING\n\"The Shallows\" by Josh Thies", "NOW PLAYING\n\"The Leviathan\" by Zachary Baker", "", "NOW PLAYING\n\"The Whalefall\" by Josh Thies", "NOW PLAYING\n\"Deus Est Cancri\" by Josh Thies"]

var isFading = false
var isVolumeIncrease = false
var isVolumeDecrease = false
var volume_amt = 0.0
var linearSliderValue = 0.9

func _ready() -> void:
	background_music.volume_db = 20 * (log(linearSliderValue) / log(10))
	match Global.SCENE:
		"TheShallows":
			change_music(0)
			var eel_script = get_node("/root/Node2D/LeviathanEel")
			eel_script.bgmusic_chase.connect(change_music.bind(1))
			eel_script.bgmusic_stop.connect(change_music.bind(-1))
			eel_script.bg_music_lower_volume.connect(change_volume.bind(-1))
			eel_script.bg_music_raise_volume.connect(change_volume.bind(1))
		"WhalefallSettlement":
			change_music(4)
		"bossfight":
			change_music(4)
		_:
			pass
		
	
	var dialogue_script = get_node("/root/Node2D/DialogueManager")
	var nauto_script = get_node("/root/Node2D/Nauto")
	
	dialogue_script.bg_music_lower_volume.connect(change_volume.bind(-1))
	dialogue_script.bg_music_raise_volume.connect(change_volume.bind(1))
	dialogue_script.bgmusic_stop.connect(change_music.bind(-1))
	dialogue_script.bgmusic_rumble.connect(change_music.bind(2))
	nauto_script.bgmusic_rumble.connect(change_music.bind(2))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print (background_music.volume_db)
	if isFading == true:
		color.a -= 0.002
		music_credit.add_theme_color_override("default_color", color)
	if color.a == 0:
		isFading = false
	
	if isVolumeDecrease == true:
		preset_volume = background_music.volume_db
		background_music.volume_db = lerp(background_music.volume_db, preset_volume + 20 * (log(linearSliderValue) / log(10)), delta)
		if background_music.volume_db <= 20 * (log(linearSliderValue) / log(10)):
			isVolumeDecrease = false
	if isVolumeIncrease == true:
		preset_volume = background_music.volume_db
		background_music.volume_db = lerp(background_music.volume_db, preset_volume - 20 * (log(linearSliderValue) / log(10)), delta )
		if background_music.volume_db >= 20 * (log(linearSliderValue) / log(10)):
			isVolumeIncrease = false

func _on_timer_timeout() -> void:
	pass
	
func change_volume(direction: int) -> void:
	if direction == -1:
		print ("lower volume")
		isVolumeIncrease = false
		isVolumeDecrease = true
		linearSliderValue -= 0.1
	elif direction == 1:
		print ("raise volume")
		isVolumeIncrease = true
		isVolumeDecrease = false
		linearSliderValue += 0.1
		
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
	
	
