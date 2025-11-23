extends Node

const ContourGeneratorC		= preload("res://addons/musiclib/melodizer/ContourGenerator.gd")
const AnchorPlacerC			= preload("res://addons/musiclib/melodizer/AnchorPlacer.gd")
const SegmentBuilderC		= preload("res://addons/musiclib/melodizer/SegmentBuilder.gd")
const CandidatePoolBuilderC	= preload("res://addons/musiclib/melodizer/CandidatePoolBuilder.gd")
const CandidateFilterC		= preload("res://addons/musiclib/melodizer/CandidateFilter.gd")
const NoteChooserC			= preload("res://addons/musiclib/melodizer/NoteChooser.gd")
const MelodyAssemblerC		= preload("res://addons/musiclib/melodizer/MelodyAssembler.gd")
const PostprocessOrnamentsC	= preload("res://addons/musiclib/melodizer/PostprocessOrnaments.gd")

#--------------------------------------------------------------------------------
# SIMULATION DE TEST
#--------------------------------------------------------------------------------
func _ready() -> void:
	print("\n=== TEST MELODIZER PIPELINE ===")

	# Simule 4 HarmonicFrames avec des durées simples
	var harmonic_frames = _fake_frames()

	# Profil de style minimal
	var style_profile = {
		"target_density": 0.5,
		"climax_at": 0.6
	}

	# Étape 1 : registre global
	var contour_gen = ContourGeneratorC.new()
	var contour = contour_gen.generate_contour(harmonic_frames.size(), style_profile, Vector2(60,80), "arch")

	# Étape 2 : ancrages
	var placer = AnchorPlacerC.new()
	var anchors = placer.place_anchors(harmonic_frames, contour, style_profile)

	# Étape 3 : segments
	var seg_builder = SegmentBuilderC.new()
	var segments = seg_builder.build_segments(anchors, harmonic_frames, {})

	# Étape 4 : pools candidats
	var pool_builder = CandidatePoolBuilderC.new()
	for hf in harmonic_frames:
		hf.chord_context.free_space = pool_builder.build_pool_for_frame(hf)

	# Étape 5 : choix de notes par segment
	var note_chooser = NoteChooserC.new()
	var seg_results = []
	for seg in segments:
		var before = _frame_by_id(harmonic_frames, seg.start_anchor.frame_id)
		var after = _frame_by_id(harmonic_frames, seg.end_anchor.frame_id)
		var melody = note_chooser.choose_for_segment(seg, before, after, style_profile.target_density)
		seg_results.append(melody)

	# Étape 6 : assemblage
	var assembler = MelodyAssemblerC.new()
	var melody_full = assembler.assemble_melody(seg_results)

	print("\n--- Mélodie avant ornements ---")
	_print_melody(melody_full)

	# Étape 7 : post-process (ornements)
	var post = PostprocessOrnamentsC.new()
	var melody_final = post.process(melody_full, harmonic_frames)

	print("\n--- Mélodie après ornements ---")
	_print_melody(melody_final)

	print("\n✅ Pipeline de test terminé.")
	print("Frames:", harmonic_frames.size(), " Anchors:", anchors.size(), " Segments:", segments.size(), " Notes:", melody_final.size())

#--------------------------------------------------------------------------------
# OUTILS
#--------------------------------------------------------------------------------
func _fake_frames() -> Array:
	var frames = []
	var chords = ["I", "V", "vi", "IV"]
	var base_time = 0.0
	var dur = 2.0

	var i = 0
	while i < chords.size():
		var hf = {
			"id": i,
			"time_in": base_time,
			"time_out": base_time + dur,
			"chord_context": {
				"symbol": chords[i],
				"degrees": [1,3,5],
				"available_tensions": [9],
				"free_space": [],
			},
			"scale_context": {
				"pitch_set": [0,2,4,5,7,9,11]
			},
			"satb_snapshot": {
				"S": 72, "A": 67, "T": 60, "B": 52
			},
			"register_window": Vector2(60,80)
		}
		frames.append(hf)
		base_time += dur
		i += 1
	return frames

func _frame_by_id(frames, fid):
	for f in frames:
		if f["id"] == fid:
			return f
	return null

func _print_melody(mel: Array) -> void:
	var i = 0
	while i < mel.size():
		var n = mel[i]
		var pitch = int(n["pitch"])
		var tin = float(n["time_in"])
		var tout = float(n["time_out"])
		var dur = tout - tin
		print("  •", pitch, " (", str(tin), "→", str(tout), ", dur:", str(dur), ")")
		i += 1
