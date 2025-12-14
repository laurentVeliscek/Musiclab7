extends VBoxContainer

const TAG ="shiftVoicingContainer" 

onready var pattern_line = $"../Pattern/pattern_lineEdit"
onready var scene = $".."


func _on_up_voicings_pressed():
	apply_offset(1)
	
func _on_down_voicings_pressed():
	apply_offset(-1)
	
func apply_offset(delta:int):
	scene.rewind()
	scene.midi_player.stop()
	#var grid = scene.gp.chord_grid
	var progression_track = scene.myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	
	var degrees_with_start = progression_track.get_degrees_with_start()
	for i in range(0,degrees_with_start.size()):
		var dic = degrees_with_start[i]
		var d:Degree = dic["degree"]
		var chords = d.guitar_chords()
		var index_voicing = d.chord_voicing_index
		var new_index = (index_voicing + chords.size() + delta) % chords.size()
		#var start = dic["start"]
		d.chord_voicing_index = new_index
		var gc:GuitarChord = chords[new_index]
		gc.start = dic["start"]
		gc.length_beats = d.length_beats
		scene.gp.chord_grid[i] = gc.clone()
	
	
	var display_degree:Degree =  progression_track.events[scene.selected_chord_index]["degree"]	
	var display_index =	display_degree.chord_voicing_index
	var current_display_gc = display_degree.guitar_chords()[display_degree.chord_voicing_index]
	
	$"../voicingContainer/voicing_view".set_voicing_index(display_index)
	scene.play_chord(current_display_gc)
	LogBus.info(TAG,"All guitar chords voicings shifted by "+str(delta))
	update()
			
	


func _on_random_single_btn_pressed():
	scene.rewind()
	scene.midi_player.stop()
	#var grid = scene.gp.chord_grid
	var progression_track = scene.myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)	


	var display_degree = progression_track.get_degrees_with_start()[scene.selected_chord_index]["degree"]
	var guitar_chords =  display_degree.guitar_chords()
	var display_index =	display_degree.chord_voicing_index
	var number_of_chords = guitar_chords.size()
	display_degree.chord_voicing_index = MusicLabGlobals.rng.randi() % number_of_chords
	var current_display_gc = guitar_chords[display_degree.chord_voicing_index].clone()
	
	$"../voicingContainer/voicing_view".set_voicing_index(display_index)
	scene.play_chord(current_display_gc.clone())
	LogBus.info(TAG,"Voicing randomized to voicing #" + str(display_degree.chord_voicing_index))
	update()




func _on_random_all_btn_pressed():
	scene.rewind()
	scene.midi_player.stop()
	#var grid = scene.gp.chord_grid
	var progression_track = scene.myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	
	var degrees_with_start = progression_track.get_degrees_with_start()
	for i in range(0,degrees_with_start.size()):
		var dic = degrees_with_start[i]
		var d:Degree = dic["degree"]
		var chords = d.guitar_chords()
		#var index_voicing = d.chord_voicing_index
		var new_index = MusicLabGlobals.rng.randi() % chords.size()
		#var start = dic["start"]
		d.chord_voicing_index = new_index
		var gc:GuitarChord = chords[new_index]
		gc.start = dic["start"]
		gc.length_beats = d.length_beats
		scene.gp.chord_grid[i] = gc.clone()
	
	
	var display_degree:Degree =  progression_track.events[scene.selected_chord_index]["degree"]	
	var display_index =	display_degree.chord_voicing_index
	var current_display_gc = display_degree.guitar_chords()[display_degree.chord_voicing_index]
	
	$"../voicingContainer/voicing_view".set_voicing_index(display_index)
	scene.play_chord(current_display_gc)
	LogBus.info(TAG,"All guitar chords voicings randomized")
	update()


func _on_Reset_voicing_btn_pressed():
	scene.rewind()
	scene.midi_player.stop()
	#var grid = scene.gp.chord_grid
	var progression_track = scene.myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	
	var degrees_with_start = progression_track.get_degrees_with_start()
	for i in range(0,degrees_with_start.size()):
		var dic = degrees_with_start[i]
		var d:Degree = dic["degree"]
		var chords = d.guitar_chords()
		#var index_voicing = d.chord_voicing_index
		var new_index = 0
		#var start = dic["start"]
		d.chord_voicing_index = new_index
		var gc:GuitarChord = chords[new_index]
		gc.start = dic["start"]
		gc.length_beats = d.length_beats
		scene.gp.chord_grid[i] = gc.clone()
	
	
	var display_degree:Degree =  progression_track.events[scene.selected_chord_index]["degree"]	
	var display_index =	display_degree.chord_voicing_index
	var current_display_gc = display_degree.guitar_chords()[display_degree.chord_voicing_index]
	
	$"../voicingContainer/voicing_view".set_voicing_index(display_index)
	scene.play_chord(current_display_gc)
	LogBus.info(TAG,"All guitar chords voicings randomized")
	update()
			
