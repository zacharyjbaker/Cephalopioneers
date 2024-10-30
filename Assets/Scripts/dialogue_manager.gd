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
var dialogue_file_path = "res://Assets/Sound/Dialogue/" + dialogue_instance + "." + dialogue_stage + ".wav"


var DialogueDict = {
	"Level1" : {
		"1": "/B/Nauto, have you reached the seafloor?.",
		"2": "/N/Just landed.",
		"3": "/B/Is there any sign of Lieutenant Anam?",
		"4": "/N/Initial scans have come back negative.",
		"5": "/N/His C.L.O.A.K. may be malfunctiong.",
		"6": "/B/Hmm...",
		"7": "/B/Very well. Conduct manual search routine.",
		"8": "/B/Report back as soon as you learn anything.",
		"9": "/END/"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.visible_characters = 0

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
					dialogue_flag = false
					dialogueBG.visible = false
					dialogueBG.set_process(false)
					dialogueBG.color="ffffff00"
					dialogue.visible = false
					dialogue.set_process(false)
					timer.stop()
					return
				"N":
					speaker = "Nauto"
					dialogueBG.color="354a42"
					dialogue.add_theme_color_override("default_color", Color("86b0ee"))
					#dialogue_stream.play()
				"B":
					speaker = "Bite"
					dialogueBG.color="4b4051"
					dialogue.add_theme_color_override("default_color", Color("c7a97c"))
					#dialogue_stream.play()
			print (speaker)
			dialogue_in_process = true
			dialogue_file_path = "res://Assets/Sound/Dialogue/" + dialogue_instance + "." + dialogue_stage + ".wav"
			print (dialogue_file_path)
			dialogue_line = dialogue_line.get_slice("/", 2)
			dialogue.text = dialogue_line

func _on_timer_timeout() -> void:
	dialogue.visible_characters += 1
	timer.start()
	
	if (dialogue.visible_characters >= dialogue_line.length()):
		dialogue_in_process = false
