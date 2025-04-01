extends Node2D
@onready var dialogue = $DialogueCanvas/Dialogue
@onready var timer = $DialogueTimer
@onready var dialogueBG = $DialogueCanvas/DialogueBG
@onready var dialogue_stream = $DialogueStream
@onready var nauto_talk = $DialogueCanvas/NautoTalk
@onready var other_talk = null
@onready var malo_talk =  $DialogueCanvas/MaloTalk
@onready var bite_talk =  $DialogueCanvas/BiteTalk
@onready var crab_talk =  $DialogueCanvas/CrabTalk
@onready var hidden_talk =  $DialogueCanvas/HiddenTalk
@export var dialogue_flag = false
var first_dialogue = false
var dialogue_in_process = false
var speaker = ""
var dialogue_line = ""
var dialogue_instance = 0
var dialogue_stage = "0"
var dialogue_stage_int = 0
var dialogue_text_color = "theme_override_colors/default_color"
var dialogue_font_path = ""
var dialogue_file_path = "res://Assets/Sound/Dialogue/" + str(dialogue_instance) + "." + dialogue_stage + ".wav"

# Import JSON file as Dictionary
var file = FileAccess.open("res://Assets/Scripts/Data/dialogue_dict.json", FileAccess.READ)
var json = JSON.new()
var parse = json.parse(file.get_as_text())
var DialogueDict = json.get_data()

# Custom signals
signal cs_eel
signal bgmusic_stop
signal bgmusic_rumble
signal crab_light
signal bg_music_lower_volume
signal bg_music_raise_volume
signal bgmusic_fight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.visible_characters = 0
	load_next_dialogue()
	#dialogue_instance = "3"
	#other_talk = $DialogueCanvas/HiddenTalk
	#dialogue_instance = Global.DIALOGUE_INSTANCE
	#load_next_dialogue()
			
	#print ("Dict:", DialogueDict)

	
func load_next_dialogue():
	if is_instance_valid(Global):
		dialogue_instance = Global.DIALOGUE_INSTANCE
		print ("DI:", dialogue_instance)
		dialogue_in_process = false
		speaker = ""
		dialogue_line = ""
		dialogue_stage = "0"
		dialogue_stage_int = 0
		dialogue_text_color = "theme_override_colors/default_color"
		dialogue_font_path = ""
		
		if dialogue_instance == 1:
			print ("dialogue 1")
			other_talk = bite_talk
		
		elif dialogue_instance == 2:
			print ("dialogue 2")
			other_talk = bite_talk
			other_talk.visible = false
			other_talk = malo_talk
			
		elif dialogue_instance == 3:
			print ("dialogue 3")
			other_talk = malo_talk
			other_talk.visible = false
			other_talk = bite_talk
		
		elif dialogue_instance == 4:
			print ("dialogue 4")
			other_talk = malo_talk
			other_talk.visible = false
			other_talk = crab_talk

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_instance_valid(Global):
		#print (Global.INTERACTABLE)
		if (Input.is_action_just_pressed("ui_cancel")):
			_disable_dialogue()
		if (Input.is_action_just_pressed("ui_accept") or Global.START == true) and dialogue_flag == false and (Global.INTERACTABLE == true or first_dialogue == false):
			nauto_talk.visible = true
			other_talk.visible = true
			dialogue_flag = true
			Global.INTERACTABLE = false
			Global.FREEZE = true
			first_dialogue = true
			dialogueBG.visible = true
			dialogueBG.set_process(true)
			dialogue.visible = true
			dialogue.set_process(true)
			bg_music_lower_volume.emit()
			bg_music_lower_volume.emit()

		if (Input.is_action_just_pressed("ui_accept") or Global.START == true) and dialogue_flag == true:
			Global.START = false
			print (other_talk)
			if (dialogue_in_process): #Skip text tick
				dialogue.visible_characters = -1
				timer.stop()
				other_talk.stop()
				nauto_talk.stop()
				dialogue_in_process = false
			else: #Text tick
				timer.start()
				dialogue.text = ""
				dialogue.visible_characters = 0
				dialogue_stage_int = int(dialogue_stage)
				dialogue_stage_int += 1
				dialogue_stage = str(dialogue_stage_int)
				dialogue_line = DialogueDict[str(dialogue_instance)][dialogue_stage]
				
				match dialogue_line.get_slice("/", 1):
					"END":
						print ("End Dialogue")
						_disable_dialogue()
						Global.DIALOGUE_INSTANCE = 2
						load_next_dialogue()
					"END":
						print ("End Dialogue")
						_disable_dialogue()
						#Global.DIALOGUE_INSTANCE = 3
						#load_next_dialogue()
					"ENDCRAB":
						print ("End Dialogue")
						_disable_dialogue()
						Global.BOSS_FIGHT = true
						bgmusic_fight.emit()
						Global.SHAKE = false
					"ENDEEL":
						print ("End Dialogue")
						_disable_dialogue()
						
						# Trigger eel cutscene
						if speaker == "Malo":
							cs_eel.emit()
							print ("start cutscene")
						load_next_dialogue()
						return
					"N":
						_load_nauto()
					"S":
						_load_nauto()
						print ("begin shaking")
						Global.SHAKE = true
						bgmusic_rumble.emit()
					"B":
						_load_bite()
					"M":
						_load_malo()
					"C":
						_load_crab()
					"C_S":
						_load_crab()
						print ("begin shaking")
						Global.SHAKE = true
						bgmusic_rumble.emit()
					"C_F":
						_load_crab()
						crab_light.emit()
					"C_H":
						_load_hidden()
						
				print (speaker)
				if (load(dialogue_file_path) != null):
					dialogue_stream.stream = load(dialogue_file_path)
					dialogue_stream.play()
				dialogue_in_process = true
				print (dialogue_file_path)
				dialogue_line = dialogue_line.get_slice("/", 2)
				dialogue.text = dialogue_line

func _on_timer_timeout() -> void:
	if is_instance_valid(Global):
		dialogue.visible_characters += 1
		timer.start()
		
		if (dialogue.visible_characters >= dialogue_line.length()):
			dialogue_in_process = false
			other_talk.stop()
			nauto_talk.stop()
		
func _disable_dialogue() -> void:
	dialogue_flag = false
	dialogueBG.visible = false
	dialogueBG.set_process(false)
	#dialogueBG.color="ffffff00"
	dialogue.visible = false
	dialogue.set_process(false)
	timer.stop()
	nauto_talk.visible = false
	other_talk.visible = false
	Global.FREEZE = false

func _load_bite() -> void:
	other_talk = bite_talk
	nauto_talk.stop()
	other_talk.play("Talk")
	speaker = "Bite"
	#dialogueBG.color="4b4051"
	dialogue.add_theme_color_override("default_color", Color("c7a97c"))
	dialogue_font_path = load("res://Assets/Fonts/Bite.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	dialogue_file_path = "res://Assets/Sound/Dialogue/B" + str(dialogue_instance) + "-" + dialogue_stage + ".wav"

func _load_malo() -> void:
	other_talk = malo_talk
	nauto_talk.stop()
	other_talk.play("Talk")
	speaker = "Malo"
	#dialogueBG.color="101218"
	dialogue.add_theme_color_override("default_color", Color("c9dfba"))
	dialogue_font_path = load("res://Assets/Fonts/Bite.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	dialogue_file_path = "res://Assets/Sound/Dialogue/M" + str(dialogue_instance) + "-" + dialogue_stage + ".wav"

func _load_nauto() -> void:
	nauto_talk.play("Talk")
	other_talk.stop()
	speaker = "Nauto"
	#dialogueBG.color="354a42"
	dialogue.add_theme_color_override("default_color", Color("86b0ee"))
	dialogue_font_path = load("res://Assets/Fonts/Nauto2.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	dialogue_file_path = "res://Assets/Sound/Dialogue/N" + str(dialogue_instance) + "-" + dialogue_stage + ".wav"

func _load_crab() -> void:
	print ("load crab")
	other_talk = crab_talk
	$DialogueCanvas/HiddenTalk.visible = false
	$DialogueCanvas/CrabTalk.visible = true
	nauto_talk.stop()
	crab_talk.play("Talk")
	speaker = "Crab"
	#dialogueBG.color="301934"
	dialogue.add_theme_color_override("default_color", Color("00A36C"))
	dialogue_font_path = load("res://Assets/Fonts/Crab3.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	#dialogue_file_path = "res://Assets/Sound/Dialogue/N" + str(dialogue_instance) + "-" + dialogue_stage + ".wav"

func _load_hidden() -> void:
	print ("load hidden")
	other_talk = hidden_talk
	nauto_talk.stop()
	hidden_talk.play("Talk")
	speaker = "Crab"
	#dialogueBG.color="301934"
	dialogue.add_theme_color_override("default_color", Color("00A36C"))
	dialogue_font_path = load("res://Assets/Fonts/Crab3.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	#dialogue_file_path = "res://Assets/Sound/Dialogue/N" + str(dialogue_instance) + "-" + dialogue_stage + ".wav"
