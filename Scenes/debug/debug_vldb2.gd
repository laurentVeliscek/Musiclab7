extends Control


const TAG = "[debug_vldb.gd]"

onready var vldb_reader = $vldb_reader





func run_test_vldb():

	#func get_triad(chord_root:int=0, quality:String="maj", inversion:int=0, max_lines:int=-1, apply_tessiture:bool=false) -> Array:
	VLDBReader.load_default()
	var satb_Dm_chord_list = VLDBReader.get_triad(2, "min", 0, -1, true)
	#_print(str(satb_list))
	_print("satb_Dm_chord_list.size() = ",satb_Dm_chord_list.size())
	for c in satb_Dm_chord_list:
		_print("Testing " + str(c) + " = " + get_jazz_chord(c))
		# looking for G triad
		var request = {}
		request["satb_from"] = c
		request["target_root_delta_set"] = [4]
		request["kinds"] = ["triad"]
		#request["target_inversions"] = [0,1]
		request["target_qualities"] = ["maj","min"]
		request["apply_tessiture"] = false

		_print(request)
		var SATB_arrays = VLDBReader.find_transition(request)
		if SATB_arrays.size() == 0:
			_print("no solution for from = "+str(c))
		else:
			for s in SATB_arrays:
				_print(SATB_arrays.size()," solutions for from = "+str(c))
				_print("- "+str(s))
		_print("\nTEST find_transition_from_text")
		var txt = "triad maj, dt=4, inv={0,1}, tess=true, unison=false, limit=50"
		var res = VLDBReader.find_transition_from_text(txt, PoolIntArray(c))
		_print("res.size()", res.size())
		if res.size() == 0 :
			_print("No solution with find from text for "+ str(c))
		else:
			for s in res:
				_print("> " , s)
	
	
	
	

#################################
	

func convert_midi_notes_to_string(arr:Array) -> String:
	var txt = ""
	for n in arr:
		txt += NoteParser.midipitch2String(n) + " "

	return txt
	
func _ready():
	#connection à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	run_test_vldb()
	
	
	
func _on_log_entry(entry):
	#entry = {time_str, msec, level, tag, message}
	var level = entry["level"]
	var tag = entry["tag"]
	var message = entry["message"]
	$logBusConsole_TXT.text += level + "|"  + tag + "|" + message + "\n"

#############################################################################
#   HELPER LogBus -> NE PAS TOUCHER
#############################################################################

func _print(s1="",s2="",s3="",s4="",s5="",
		s6="",s7="",s8="",s9="",s10="",
		s11="",s12="",s13="",s14="",s15="",
		s16="",s17="",s18="",s19="",s20=""):
			
	var s = str(s1) + " " + str(s2) + " " + str(s3) + " " + str(s4) + " " + str(s5) + " "
	s += str(s6) + " " + str(s7) + " " + str(s8) + " " + str(s9) + " " + str(s10) + " "	
	s += str(s11) + " " + str(s12) + " " + str(s13) + " " + str(s14) + " " + str(s15) + " "
	s += str(s16) + " " + str(s17) + " " + str(s18) + " " + str(s19) + " " + str(s20) + " "		
	LogBus.debug(TAG,s)
	print(s)




static func get_chord_and_scale( notes:Array, music_chord:int = 0 ):
	#
	# 和音と調を解析する
	# @param	notes			MIDI note numbers
	# @param	music_chord		music chord (default C)
	# @return	if find: { root: _, chord: _, string: _ } not found: null
	#

	var chord_table:Array = []
	var octave:PoolIntArray = PoolIntArray( [0,0,0,0,0,0,0,0,0,0,0,0] )
	for note in notes: octave[note % 12] = 1
	var sound_count:int = 0
	for i in octave: sound_count += i

	if sound_count == 5:
		chord_table = [
			{ "name": "7(b9)", "notes": [ 4, 7, 10, 13 ] },
			{ "name": "9", "notes": [ 4, 7, 10, 14 ] },
		]
	elif sound_count == 4:
		chord_table = [
			{ "name": "sus4(13)", "notes": [ 5, 7, 9 ] },
			{ "name": "aug M7", "notes": [ 4, 8, 11 ] },
			{ "name": "dim7", "notes": [ 3, 6, 9 ] },
			{ "name": "7sus4", "notes": [ 5, 7, 10 ] },
			{ "name": "m7(-5)", "notes": [ 3, 6, 10 ] },
			{ "name": "mM7", "notes": [ 3, 7, 11 ] },
			{ "name": "m7", "notes": [ 3, 7, 10 ] },
			{ "name": "M7", "notes": [ 4, 7, 11 ] },
			{ "name": "7", "notes": [ 4, 7, 10 ] },
			{ "name": "m6", "notes": [ 3, 7, 9 ] },
			{ "name": "6", "notes": [ 4, 7, 9 ] },
		]
	elif sound_count == 3:
		chord_table = [
			{ "name": "sus4", "notes": [ 5, 7 ] },
			{ "name": "sus2", "notes": [ 2, 7 ] },
			{ "name": "aug", "notes": [ 4, 8 ] },
			{ "name": "dim", "notes": [ 3, 6 ] },
			{ "name": "m", "notes": [ 3, 7 ] },
			{ "name": "", "notes": [ 4, 7 ] },
		]
	#elif sound_count == 2:
	#	chord_table = [
	#		{ "name": "power", "notes": [ 5 ] },
	#	]
	else:
		return null

	for i in range( 0, 12 ):
		var root_note:int = ( i + music_chord ) % 12
		if octave[root_note] == 0: continue

		for chord in chord_table:
			var found:bool = true
			for note in chord.notes:
				if octave[(root_note + note) % 12] == 0:
					found = false
					break
			if found:
				return {
					"root": root_note,
					"chord": chord.name,
					"string": "%s%s" % [
						["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"][root_note],
						chord.name
					]}

	return null


func get_jazz_chord(chord_array) -> String :
	
	#var res = get_chord_and_scale(chord_array, (key.root_midi) % 12  )
	var res = get_chord_and_scale(chord_array)
	if res != null :
		return str(res["string"])
	else:
		return "?"
