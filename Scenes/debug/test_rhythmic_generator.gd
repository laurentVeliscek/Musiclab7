# test_rhythmic_generator.gd
extends Node

func _ready():
	print("=== Test Générateur de Motifs Rythmiques ===\n")
	
	var generator = RhythmicMotifGenerator.new()
	
	# Test 1 : Motif simple
	print("--- Test 1 : Motif simple ---")
	var params1 = {
		"frame_size": 4.0,
		"n_notes": 6,
		"density": 0.7,
		"density_tolerance": 0.1,
		"syncopation": 0.3,
		"triplet_feel": 0.0,
		"repetition_factor": 0.5,
		"position": "start",
		"seed": 12345
	}
	
	var motif1 = generator.generate_motif(params1)
	_print_motif(motif1, "Motif 1")
	
	# Test 2 : Motif syncopé
	print("\n--- Test 2 : Motif syncopé ---")
	var params2 = {
		"frame_size": 4.0,
		"n_notes": 8,
		"density": 0.8,
		"syncopation": 0.8,
		"triplet_feel": 0.0,
		"repetition_factor": 0.7,
		"position": "center",
		"seed": 54321
	}
	
	var motif2 = generator.generate_motif(params2)
	_print_motif(motif2, "Motif 2")
	
	# Test 3 : Motif ternaire
	print("\n--- Test 3 : Motif ternaire ---")
	var params3 = {
		"frame_size": 4.0,
		"n_notes": 5,
		"density": 0.6,
		"syncopation": 0.2,
		"triplet_feel": 0.9,
		"repetition_factor": 0.3,
		"position": "end",
		"seed": 99999
	}
	
	var motif3 = generator.generate_motif(params3)
	_print_motif(motif3, "Motif 3")

func _print_motif(motif: Array, title: String) -> void:
	print(title + ":")
	print("  Nombre de notes: ", motif.size())
	
	var total_duration = 0.0
	for note in motif:
		total_duration += note["length_beats"]
	print("  Durée totale: ", stepify(total_duration, 0.01), " beats")
	
	print("  Détail:")
	for i in range(motif.size()):
		var note = motif[i]
		print("    Note ", i + 1, ": start=", stepify(note["start"], 0.01), 
			" dur=", stepify(note["length_beats"], 0.01), 
			" brick=", note["brick_id"])

