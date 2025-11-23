extends Control


const TAG = "[debug_vldb.gd]"

onready var vldb_reader = $vldb_reader





func run_test_vldb():

		
		
# FIRST TEST
#	var src = vldb_reader.find_voicing(0, 0, 3, 4, 0, PoolIntArray([0,0,0]))	# triade maj inv0 rel 0
#	print("src -> " + str(src))
#
#	var edges = vldb_reader.get_edges(src, 7, 50)	# dt = 7 (quinte au-dessus), limite 50
#	print("EDGES -> " + str(edges))

# SECOND TEST
#	vldb_reader.load_default()
#	var src = vldb_reader.find_voicing(0, 0, 3, 4, 0, PoolIntArray([0,0,0]))
#	LogBus.debug(TAG,str("src = ", src))
#	var edges = vldb_reader.get_edges(src, -1, 50)
#	LogBus.debug(TAG,str("edges -> ", edges.size()))
#	for e in edges:
#		LogBus.debug(TAG," -> " + str(e))

# 	TROISIEME TEST 
	#VLDBReader.load_default()
#	var src = VLDBReader.find_voicing(0, 0, 3, 4, 0, PoolIntArray([0, 0, 0]))
#	_print("src=", src)
#	var all_edges = VLDBReader.get_edges(src, -1, 200)
#	for e in all_edges:
#		_print(" " + str(e))

# 	QUATRIEME TEST 
	#var vldb_reader = VLDBReader
#	var ok = vldb_reader.load_default()
#	print("OK=", ok, " stats=", vldb_reader.stats())
#
#	# Exemple : triade maj, inv0, REL 0,0,0
#	var src = vldb_reader.find_voicing(0, 0, 3, 4, 0, PoolIntArray([0,0,0]))
#	print("SRC=", src)
#
#	var edges = vldb_reader.get_edges(src, -1, 50) # toutes les dt, limite 50
#	for e in edges:
#		print(e)


## 	CINQUIEME TEST 
#	var ok = VLDBReader.load_default()
#	#print("OK=", ok, " stats=", VLDBReader.stats())
#	var satb = PoolIntArray([79, 69, 64, 52])	# S,A,T,B en MIDI
#	#var src = VLDBReader.find_voicing_from_satb(0, 0, 3, 4, 0, satb)
#	var src = VLDBReader.find_voicing_from_satb(0, 1, 4, 3, 0, PoolIntArray([79,69,64,52]))
#	print("SRC=", src)
#	var edges = VLDBReader.get_edges(src, -1, 20)
#	print(edges.size(), " edges")

	# TEST 6
		
#	#################################
#	# on charge le profile 
#
#	var f = File.new()
#	var profile = _get_profile()
#
#	var tessitura = profile["tessitura"]
#	var bass_midi_min = tessitura["B"][0]
#	var bass_midi_max = tessitura["B"][0]
#
#	#run_list_c_major()
#
#	# C majeur, toutes inversions (inv_mask = 0b111 = 7), basses 40..60,
#	# strict_pc = true (seulement C/E/G dans S,A,T), pas de tessiture, limite 100
#	var rows = VLDBReader.list_triad_quality(0, "maj", 7, 40, 60, -1, true, {})
#
#	# A mineur, seulement inv0 et inv1 (mask 0b011 = 3), avec tessitures SATB :
#	var tess = {
#		"S": PoolIntArray([60, 84]),
#		"A": PoolIntArray([55, 77]),
#		"T": PoolIntArray([48, 69]),
#		"B": PoolIntArray([40, 60])
#	}
#	var rows2 = VLDBReader.list_triad_quality(9, "min", 3, 40, 60, 50, true, tess)
#
#	var mes_rows  = rows 
#	_print("nombre d'accords: " + str(rows2.size()))
#	for r in mes_rows:
#		var txt_add = " Notes: " + convert_midi_notes_to_string(r["satb_u8"]) + "| Chord >> " + get_jazz_chord(r["satb_u8"])
#		_print(str(r)+ " | " + txt_add)
#
##	# TEST 7
#	var satb_list = VLDBReader.get_triad(11, "dim", 1, -1, false)
#	for notes in satb_list :
#		_print(str(notes) + " -> " +  get_jazz_chord(notes))
#
#
	
#test 8
	#func get_triad(chord_root:int=0, quality:String="maj", inversion:int=0, max_lines:int=-1, apply_tessiture:bool=false) -> Array:
#	VLDBReader.load_default()
#	var satb_list = VLDBReader.get_triad(0, "maj", 0, -1, false)
#	_print(str(satb_list))
#	var my_satb = satb_list[12]
#
#	for notes in satb_list :
#		_print(str(notes) + " -> " +  get_jazz_chord(notes))
	
# TRANSITIONS — API clé de voûte
# request := {
#   "satb_from": PoolIntArray([S,A,T,B])     # OBLIGATOIRE
#   "target_root_delta": int (0..11)         # optionnel -> sinon tous
#   "target_kind": String("triad"|"tetrad")  # optionnel -> sinon les 2
#   "target_quality": String("maj"|"min"|"dim"|"aug")  # OBLIGATOIRE
#   "target_seventh_is_minor": bool          # requis si target_kind == "tetrad", sinon warning + triades only
#   "target_inversion": int (0..3)           # optionnel
#   "max_lines": int (-1 = illimité)         # optionnel
#   "apply_tessiture": bool                  # optionnel
#   "has_fifth": bool                        # optionnel -> si absent: on accepte les 2
#   "unison": bool                           # optionnel -> si absent: on accepte les 2
#   "has_doubled_seventh": bool              # optionnel -> si absent: on REJETTE les doubles 7e (règle projet)
# }
# Retour: Array de { "satb": PoolIntArray([S,A,T,B]), "score": int }
# ================================================================




	#func get_triad(chord_root:int=0, quality:String="maj", inversion:int=0, max_lines:int=-1, apply_tessiture:bool=false) -> Array:
	VLDBReader.load_default()
	var satb_list = VLDBReader.get_triad(0, "maj", 0, -1, false)
	#_print(str(satb_list))
	for b in satb_list:
		_print(str(b) + " -> " +  get_jazz_chord(b))
		
	#VLDBReader.find_transition()
	
	
	
	
	
	
	
	
	
func _mod12(x:int) -> int:
	var r = x % 12
	if r < 0:
		r += 12
	return r

var profile = {}

func _get_profile():
	var f = File.new()
	if not f.file_exists("res://Factory/profile.json"):
		profile = {
			"tessitura": {"B":[40,60],"T":[48,72],"A":[45,69],"S":[52,80]},
			"spacing": {"max_TA": 12, "max_AS": 12},
			"steps_max": {"S": 5, "A": 5, "T": 5, "B": 8},
			"weights": {"smooth": 1, "s_leap": 3, "at_leap": 2, "b_leap": 1, "outer": 2, "s_step": 1, "at_step": 1}
		}
		return
	if f.open("res://Factory/profile.json", File.READ) != OK:
		push_error("Impossible d'ouvrir profile.json"); return
	var pr = JSON.parse(f.get_as_text()); f.close()
	if pr.error != OK:
		push_error("JSON invalide dans profile.json"); return
	profile = pr.result
	return profile



func _root_pc_for_voicing_and_bass(v:Dictionary, B:int) -> int:
	var inv = int(v["inv"])
	var t3 = int(v["t3"])
	var t5 = int(v["t5"])
	var off = 0
	if inv == 1:
		off = t3
	elif inv == 2:
		off = t3 + t5
	return _mod12(B - off)
	



func list_c_major_satb(bass_min:int, bass_max:int, limit:int) -> Array:
	var out = []
	var n = VLDBReader.get_voicing_count()
	for i in range(n):
		var v = VLDBReader.get_voicing(i)
		if v.empty():
			continue
		if int(v["kind"]) != 0:
			continue
		if int(v["t3"]) != 4 or int(v["t5"]) != 3:
			continue
		var relDS = int(v["relDS"])
		var relDA = int(v["relDA"])
		var relDT = int(v["relDT"])
		var inv = int(v["inv"])
		for B in range(bass_min, bass_max + 1):
			# on force la fondamentale à C (pc 0)
			if _root_pc_for_voicing_and_bass(v, B) != 0:
				continue
			var S = B + relDS
			var A = B + relDA
			var T = B + relDT
			# (optionnel) garde-fous tessiture ici si tu veux filtrer
			out.append({
				"id": i,
				"inv": inv,
				"bass": B,
				"satb_u8": PoolIntArray([S, A, T, B]),
				"rel": PoolIntArray([relDS, relDA, relDT])
			})
			if limit > 0 and out.size() >= limit:
				return out
	return out

# --- exemple d’appel ---
func run_list_c_major():
	# charge le magasin si pas déjà fait
	VLDBReader.load_default()
	# par exemple: toutes les basses MIDI de 40 à 60, limite 100 résultats

	var rows = list_c_major_satb(40, 60, 100)
	_print("C major SATB count = ", rows.size())
	for r in rows:
		_print("id=", r["id"], " inv=", r["inv"], " B=", r["bass"], " SATB=", r["satb_u8"], 
		" Notes: "+ convert_midi_notes_to_string(r["satb_u8"]), "| Chord >> " + get_jazz_chord(r["satb_u8"]) )

	
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
