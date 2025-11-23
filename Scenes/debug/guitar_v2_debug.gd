extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("coucou")
	# VOS ENTRÉES
	var scale = [60, 62, 64, 65, 67, 69, 71]  # Do majeur (7 notes MIDI)
	var mes_notes = [60, 64, 67,71]
	var results = ChordsDB.find_chords_from_midi(mes_notes, scale,true)
	#print(str(results))
	print(str(results[0]))

		#print(result.chord_name)      # "Cmajor"
		#print(result.midi)   # [0, 4, 7]
		#print(result.position.frets)  # [-1, 3, 2, 0, 1, 0]
		#print(result.match_score)     # 0.95
		#print("to_string: " + str(result))
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
