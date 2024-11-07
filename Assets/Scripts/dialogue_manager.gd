extends Node2D
@onready var dialogue = $DialogueCanvas/Dialogue
@onready var timer = $DialogueTimer
@onready var dialogueBG = $DialogueCanvas/DialogueBG
@onready var dialogue_stream = $DialogueStream
@export var dialogue_flag = true;
var dialogue_in_process = false;
var speaker = ""
var dialogue_line = ""
var dialogue_instance = "Level1"
var dialogue_stage = "0"
var dialogue_stage_int = 0
var dialogue_text_color = "theme_override_colors/default_color"
var dialogue_font_path = ""
var dialogue_file_path = "res://Assets/Sound/Dialogue/" + dialogue_instance + "." + dialogue_stage + ".wav"

# Import JSON file as Dictionary
var file = FileAccess.open("res://Assets/Scripts/Data/dialogue_dict.json", FileAccess.READ)
var json = JSON.new()
var parse = json.parse(file.get_as_text())
var DialogueDict = json.get_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.visible_characters = 0
	#print ("Dict:", DialogueDict)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and dialogue_flag == true:
		if (dialogue_in_process): #Skip text tick
			dialogue.visible_characters = -1
			timer.stop()
			dialogue_in_process = false
		else: #Text tick
			timer.start()
			dialogue.text = ""
			dialogue.visible_characters = 0
			dialogue_stage_int = int(dialogue_stage)
			dialogue_stage_int += 1
			dialogue_stage = str(dialogue_stage_int)
			dialogue_line = DialogueDict[dialogue_instance][dialogue_stage]
			
			match dialogue_line.get_slice("/", 1):
				"END":
					print ("End Dialogue")
					_disable_dialogue()
					return
				"N":
					_load_nauto()
				"B":
					_load_bite()
					
			print (speaker)
			if (load(dialogue_file_path) != null):
				dialogue_stream.stream = load(dialogue_file_path)
				dialogue_stream.play()
			dialogue_in_process = true
			print (dialogue_file_path)
			dialogue_line = dialogue_line.get_slice("/", 2)
			dialogue.text = dialogue_line

func _on_timer_timeout() -> void:
	dialogue.visible_characters += 1
	timer.start()
	
	if (dialogue.visible_characters >= dialogue_line.length()):
		dialogue_in_process = false
		
func _disable_dialogue() -> void:
	dialogue_flag = false
	dialogueBG.visible = false
	dialogueBG.set_process(false)
	dialogueBG.color="ffffff00"
	dialogue.visible = false
	dialogue.set_process(false)
	timer.stop()

func _load_bite() -> void:
	speaker = "Bite"
	dialogueBG.color="4b4051"
	dialogue.add_theme_color_override("default_color", Color("c7a97c"))
	dialogue_font_path = load("res://Assets/Fonts/Bite.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	dialogue_file_path = "res://Assets/Sound/Dialogue/B" + dialogue_instance + "-" + dialogue_stage + ".wav"

func _load_nauto() -> void:
	speaker = "Nauto"
	dialogueBG.color="354a42"
	dialogue.add_theme_color_override("default_color", Color("86b0ee"))
	dialogue_font_path = load("res://Assets/Fonts/Nauto.ttf")
	dialogue.add_theme_font_override("normal_font", dialogue_font_path)
	dialogue_file_path = "res://Assets/Sound/Dialogue/N" + dialogue_instance + "-" + dialogue_stage + ".wav"
