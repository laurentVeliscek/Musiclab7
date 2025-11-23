extends Control




const mySoundFontPath = "res://soundfonts/Aspirin-Stereo.sf2"


const Levels = [
	{
		"suffixes":[""],
		"comment":"Une seule note de poney !"	
	},
	{
		
		"suffixes":["major","minor"],
		"comment":"Les accords majeurs et mineurs sans frou-frou..."	
	},
	{
		
		"suffixes":["sus4"],
		"comment":"Les accords majeurs et mineurs AVEC frou-frou... (sus4)"	
	},	
	{
		
		"suffixes":["","m"],
		"comment":"Mineurs / majeurs renversés (ca devient plus amusant)"	
	},
	{
		
		"suffixes":["dim"],
		"comment":"Accords diminués: il faut trouver la basse à la tierce (chaud...)"	
	},
#	{
#
#		"suffixes":["aug"],
#		"comment":"Augmented chords, tension chord... (symmetrical chord) !"	
#	},
	{
		
		"suffixes":["7","m7","maj7"],
		"comment":"Accords avec septième (jazzy pony style)"	
	},
	{
		"suffixes":["7","m7","maj7","69","m69"],
		"comment":"Accords Septièmes et 6/9 (crès choli)"	
	},
	{
		
		"suffixes":["9","add9","m9","madd9"],
		"comment":"Jazzy du neuvième étage (accords 7 et 9) "	
	},
	{
		
		"suffixes":["major","minor","sus4","sus47","7","m7","maj7","9","69","m69","add9","m9","madd9"],
		"comment":"Master pony level: un peu de tout et des surprises"	
	},
	
	{
		
		"suffixes":["major","minor","dim","dim7","sus","sus2","sus4","sus2sus4","7sus4","7/G","alt","aug","5","6","69","7","7b5","aug7","9","9b5","aug9","7b9","7#9","11","9#11","13","maj7","maj7b5","maj7#5","maj7sus2","maj9","maj11","maj13","m6","m69","m7","m7b5","m9","m11","mmaj7","mmaj7b5","mmaj9","mmaj11","add9","madd9","add11"],
		"comment":"Professionnal pony master level. (infaisable ;-)"	
	}
	
]




onready var midi_player:MidiPlayer

onready var bass_program_ob:OptionButton = $sound_settings/bass/bass_program_ob
onready var chord_program_ob:OptionButton = $sound_settings/chords/chords_program_ob
onready var bass_vol_sl:HSlider = $sound_settings/bass/bass_vol_sl
onready var chord_vol_sl:HSlider = $sound_settings/chords/chords_vol_sl
onready var bass_note_lbl: Label = $bass_note_lbl
onready var bass_octave_sl:HSlider = $sound_settings/bass/bass_octave_sl
onready var level_ob:OptionButton = $level_ob
onready var chord_speed_sl:HSlider = $sound_settings/chords/chord_speed_sl


var rng = RandomNumberGenerator.new()
var loader = null
var current_level
var root_notes = ["C","C#","D","Eb","E","F","F#","G","Ab","A","Bb","B"]
var chord_root_pitch = 0
var root_letter= "?"
var display_solution:bool = false
var current_symbol ="C"
var current_suffixe = ""
var current_chord_midi_notes = []
var current_song = Song.new()
var current_guitar_chord:GuitarChord
var ggb = MusicLabGlobals.GuitarBase


func _ready():
	rng.randomize()
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	
	#loader = ChordDBLoader.new()
	#loader.name = "Loader"
	#add_child(loader)
	chord_program_ob.set_program(25)
	bass_program_ob.set_program(32)
	
	
	
#	for n in root_notes:
#		var symbol = n+"m" 
#		var midinotes = get_chord(symbol)
#		print(symbol + ": " + str(midinotes))
	
	# populate level_ob
	var level_number = 0
	for d in Levels:
		level_number += 1
		level_ob.add_item("Niveau "+ str(level_number) + " - " + d["comment"])
		 
	new_chord()
	#$sound_settings/play_chord_Btn.hide()
	#$sound_settings/play_bass_Btn.hide()
		
func get_chord(chord_name:String) -> Array:
	var arr = ggb.search_by_name(chord_name)
	var chord = arr[rng.randi() % arr.size()]
	return chord.midiNotes()


func new_chord():
	$tab_label.text = ""
	if level_ob.selected == 0:
		$sound_settings/play_chord_Btn.text = "Play Note"
	else:
		$sound_settings/play_chord_Btn.text = "Play Chord"
	#$sound_settings/play_chord_Btn.show()
	#$sound_settings/play_bass_Btn.show()
	
	bass_note_lbl.text = "?"
	$chord_name_lbl.text = ""
	chord_root_pitch = rng.randi() % 12
	root_letter = root_notes[chord_root_pitch]
	current_level = level_ob.selected
	if current_level == 0:
		current_guitar_chord = null
		current_chord_midi_notes = [60 + chord_root_pitch]
		current_symbol = root_letter
		current_suffixe = ""
		play_chord()
		return
		
	var level = Levels[level_ob.selected]
	var chord_suffixes = level["suffixes"]
	
	var arr = []
	while arr == [] :
		current_suffixe = chord_suffixes[rng.randi() % chord_suffixes.size()]
		current_symbol = root_letter + current_suffixe
		if current_level == 3:
			var chord_third_pitch = (chord_root_pitch + 4) %12
			if current_suffixe == "m" :
				print("accord mineur")
				chord_third_pitch = (chord_root_pitch + 3) %12
			var slash_letter = root_notes[chord_third_pitch]
			if slash_letter != root_letter:
				current_symbol += "/" + slash_letter
		#current_chord_midi_notes = get_chord(current_symbol)
		arr = ggb.search_by_name(current_symbol)
		
	current_guitar_chord = arr[rng.randi() % arr.size()]
	print("chord : " + str(current_guitar_chord))
	current_chord_midi_notes =  current_guitar_chord.midiNotes()
	print ("current_chord_midi_notes" + str(current_chord_midi_notes))
	
	print(current_symbol + ": "+str(current_chord_midi_notes))
	play_chord()
	return

func _on_New_chord_Btn_pressed():
	new_chord()
	
func play_chord():
	midi_player.stop()
	current_song = Song.new()
	var chord_track = Track.new()
	var chord_pc = ProgramChange.new()
	chord_pc.set_channel(0)
	chord_pc.set_program(chord_program_ob.get_program())
	
	chord_track.set_program_change(chord_pc)
	print("chord_program: " + str(chord_program_ob.get_program()))
	#chord_track.adopt_program_channel = true
	#chord_track.set_program_change()
	var delta_notes = chord_speed_sl.value
	var pos = 0
	for m in current_chord_midi_notes:
		var n:Note = Note.new()
		n.velocity = int(chord_vol_sl.value)
		n.length_beats = 4
		n.midi = m
		chord_track.add_note(pos,n)
		pos += delta_notes
	current_song.add_track(chord_track)
	midi_player.load_from_bytes(current_song.get_midi_bytes_type1())
	midi_player.play()
		

func play_bass():
	bass_note_lbl.text = root_letter
	var symbol_from_gc = ""
	$chord_name_lbl.text = current_symbol
	if current_guitar_chord != null:
		symbol_from_gc = current_guitar_chord.chord_name
		#print(current_guitar_chord.get_ascii_tab())
		$tab_label.text = current_guitar_chord.get_ascii_tab()
	midi_player.stop()
	current_song = Song.new()
	var bass_track = Track.new()
	var bass_pc = ProgramChange.new()
	bass_pc.set_channel(0)
	bass_pc.set_program(bass_program_ob.get_program())
	
	bass_track.set_program_change(bass_pc)
	print("chord_program: " + str(bass_program_ob.get_program()))
	#chord_track.adopt_program_channel = true
	#chord_track.set_program_change()
	var delta_notes = .25
	var pos = 0

	var n:Note = Note.new()
	n.velocity = int(bass_vol_sl.value)
	n.length_beats = 4
	if current_suffixe == "dim":
		print("dim !!!")
		n.midi = chord_root_pitch + 36 + 3 + (bass_octave_sl.value * 12)
	else :
		n.midi = chord_root_pitch + 36 + (bass_octave_sl.value * 12)
	bass_track.add_note(pos,n)
	pos += delta_notes
	current_song.add_track(bass_track)
	midi_player.load_from_bytes(current_song.get_midi_bytes_type1())
	midi_player.play()
	
func _input(event):
	if event is InputEventKey :
		accept_event()
		if  event.is_released():
			return
		if event.pressed and (event.scancode == 78 or event.scancode == KEY_ENTER) :
			accept_event()
			new_chord()
			return
		elif event.pressed and (event.scancode == 66 or event.scancode == KEY_TAB) :
			accept_event()
			play_bass()
			return
		elif event.pressed and event.scancode == KEY_SPACE:
			accept_event()
			play_chord()
			return


func _on_play_chord_Btn_pressed():
	play_chord()


func _on_play_bass_Btn_pressed():
	play_bass()


func _on_level_ob_item_selected(index):
	current_level= level_ob.selected
	print("selected: " + str(level_ob.selected))
	if index == 0:
		$sound_settings/New_chord_Btn.text = "New Note"
		
	else: 
		$sound_settings/New_chord_Btn.text = "New Chord"
		#$sound_settings/play_chord_Btn.text = "Play Chord"
	new_chord()
