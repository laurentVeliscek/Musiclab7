extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var gb:GuitarChordDatabase = MusicLabGlobals.GuitarBase
	var chords = gb._all_chords
	print(str(chords.size()))

	#print(chords[0].to_string())
	#var chords = gb.search_by_name("F#")
	
#	for c in chords:
#		if c.chord_name == search:
#			print(c.to_string())
	
#	var chords2 = gb.search_by_name(search)
#	for c in chords2:
#		if c.chord_name == search:
#			print(c.to_string())
			
			
	# STATS
#	var numberNotes:Dictionary = {1:0,2:0,3:0,4:0,5:0,6:0}
#	for c in chords:
#		var gc: GuitarChord = c
#		numberNotes[gc.midiNotes().size()] += 1
#		if gc.midiNotes().size() == 2:
#			print("2 notes: " + gc.to_string())
#		elif gc.midiNotes().size() == 3:
#			print("3 notes: " + gc.to_string())
#		yield(get_tree(), "idle_frame") 
#
#
#	for k in numberNotes.keys():
#		print(str(k) + " -> "+str(numberNotes[k]))
	var search = "Aminor"
	var found = gb.search_by_name(search)
	
	var c:GuitarChord = found[0]
	
#	for i in range(0,10):
#		print(c.get_arp_note_with_string(i))
#
	print(str(c.to_dict()))
	print(str(c.get_bass_notes_with_string()))
	print(c.get_tab_absolute_as_array())
