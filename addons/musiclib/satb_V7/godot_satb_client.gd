extends Node

const TAG="SATB_Client"

# Configuration de l'API
#var api_url = "http://localhost:8000"
var api_url = "https://theparselmouth.com/satb-api"

# Node HTTPRequest (à ajouter comme enfant dans la scène)
onready var http_request = $"../HTTPRequest"


# Stockage du contexte de la dernière requête
var last_request_context = {}

# File d'attente pour gérer plusieurs requêtes
var request_queue = []
var is_processing = false

func _ready():
	# Connecter le signal de réponse HTTP
	http_request.connect("request_completed", self, "_on_request_completed")

# ========================================
# INTERFACE GÉNÉRIQUE UNIVERSELLE
# ========================================

func call_api(endpoint: String, request_data, context: Dictionary = {}):
	"""
	Interface universelle pour appeler n'importe quel endpoint de l'API
	Accepte Dictionary OU Array selon l'endpoint
	
	Args:
		endpoint: Le chemin de l'endpoint (ex: "/solve-chord", "/solve-progression")
		request_data: Dictionary OU Array à envoyer
		context: Données contextuelles optionnelles
	
	Exemples:
		# Un seul accord (Dictionary)
		call_api("/solve-chord", {"index": 0, "degree_number": 1, ...})
		
		# Progression (Array)
		call_api("/solve-progression", [chord1, chord2, chord3])
	"""
	# Ajouter la requête à la file d'attente
	request_queue.append({
		"endpoint": endpoint,
		"request_data": request_data,
		"context": context
	})
	
	# Traiter la file si pas déjà en cours
	if not is_processing:
		_process_next_request()

func _process_next_request():
	"""Traite la prochaine requête dans la file d'attente"""
	if request_queue.empty():
		is_processing = false
		return
	
	is_processing = true
	var req = request_queue.pop_front()
	
	# Stocker le contexte pour le callback
	last_request_context = req.context
	
	var headers = ["Content-Type: application/json"]
	
	# Déterminer la méthode HTTP
	var method = HTTPClient.METHOD_GET
	var json_body = ""
	
	if req.request_data != null:
		method = HTTPClient.METHOD_POST
		json_body = JSON.print(req.request_data)
	
	var error = http_request.request(
		api_url + req.endpoint,
		headers,
		true,
		method,
		json_body
	)
	
	if error != OK:
		print("Erreur lors de l'envoi de la requête: ", error)
		emit_signal("api_error", error, req.context)
		# Continuer avec la prochaine requête
		_process_next_request()

func _on_request_completed(result, response_code, headers, body):
	"""Callback universel appelé pour toute requête HTTP"""
	
	var context = last_request_context
	
	if response_code != 200:
		print("Erreur HTTP: ", response_code)
		print("Body: ", body.get_string_from_utf8())
		emit_signal("api_error", response_code, context)
		_process_next_request()
		return
	
	# Parser le JSON
	var json = JSON.parse(body.get_string_from_utf8())
	
	if json.error != OK:
		print("Erreur de parsing JSON: ", json.error_string)
		emit_signal("api_error", json.error, context)
		_process_next_request()
		return
	
	var response = json.result
	
	# Émettre un signal générique avec la réponse et le contexte
	emit_signal("api_response", response, context)
	
	# Affichage debug (optionnel, peut être désactivé)
	if OS.is_debug_build():
		print("=== API Response ===")
		if response.has("method"):
			print("Method: ", response.method)
		elif response.has("satb_arrays"):
			print("Progression de ", response.satb_arrays.size(), " accords")
			print("Processing time: ", response.processing_time, "s")
		print("Context: ", context)
	
	# Traiter la prochaine requête dans la file
	_process_next_request()

# ========================================
# SIGNAUX
# ========================================

# Signal émis quand une réponse API est reçue avec succès
signal api_response(response, context)

# Signal émis en cas d'erreur
signal api_error(error_code, context)

# ========================================
# HELPERS OPTIONNELS
# ========================================

func solve_chord(chord_data: Dictionary, context: Dictionary = {}):
	"""Helper pour résoudre un seul accord"""
	call_api("/solve-chord", chord_data, context)

func solve_progression(chords: Array, context: Dictionary = {}):
	"""Helper pour résoudre une progression d'accords"""
	call_api("/solve-progression", chords, context)

func test_connection():
	"""Teste la connexion à l'API avec une requête GET"""
	# Ajouter la requête à la file d'attente
	request_queue.append({
		"endpoint": "/",
		"request_data": null,  # null = requête GET
		"context": {"test": true}
	})
	
	if not is_processing:
		_process_next_request()

# ========================================
# UTILITAIRES
# ========================================

func midi_to_note(midi: int) -> String:
	"""Convertit un numéro MIDI en nom de note"""
	var notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	var octave = int(midi / 12) - 1
	var note = notes[midi % 12]
	return note + str(octave)


# ========================================
# EXEMPLE D'UTILISATION
# ========================================

"""
# Dans ton script principal :

onready var satb_client = $SATBClient

func _ready():
	# Connecter les signaux
	satb_client.connect("api_response", self, "_on_satb_received")
	satb_client.connect("api_error", self, "_on_satb_error")
	
	# Tester avec une progression
	test_progression()

func test_progression():
	var progression = []
	
	# Accord I
	progression.append({
		"index": 0,
		"pos": 0.0,
		"length_beats": 1.0,
		"key_midi_root": 0,
		"key_scale_name": "major",
		"scale_array": [0, 2, 4, 5, 7, 9, 11],
		"degree_number": 1,
		"kind": "diatonic",
		"chord_notes": [60, 64, 67],
		"func": "T",
		"limit": 5
	})
	
	# Accord IV
	progression.append({
		"index": 1,
		"pos": 1.0,
		"length_beats": 1.0,
		"key_midi_root": 0,
		"key_scale_name": "major",
		"scale_array": [0, 2, 4, 5, 7, 9, 11],
		"degree_number": 4,
		"kind": "diatonic",
		"chord_notes": [65, 69, 72],
		"func": "PD",
		"limit": 5
	})
	
	# Accord V7
	progression.append({
		"index": 2,
		"pos": 2.0,
		"length_beats": 1.0,
		"key_midi_root": 0,
		"key_scale_name": "major",
		"scale_array": [0, 2, 4, 5, 7, 9, 11],
		"degree_number": 5,
		"kind": "diatonic",
		"chord_notes": [67, 71, 74, 77],
		"func": "D",
		"limit": 5
	})
	
	# Accord I
	progression.append({
		"index": 3,
		"pos": 3.0,
		"length_beats": 2.0,
		"key_midi_root": 0,
		"key_scale_name": "major",
		"scale_array": [0, 2, 4, 5, 7, 9, 11],
		"degree_number": 1,
		"kind": "diatonic",
		"chord_notes": [60, 64, 67],
		"func": "T",
		"limit": 3
	})
	
	# Envoyer la progression
	satb_client.solve_progression(progression, {"piece": "Test I-IV-V-I"})

func _on_satb_received(response, context):
	print("\n=== Réponse SATB ===")
	print("Context: ", context)
	
	# Progression (Array)
	if response.has("satb_arrays"):
		print("Progression de ", response.satb_arrays.size(), " accords")
		print("Temps: ", response.processing_time, "s")
		
		for satb_array in response.satb_arrays:
			var req = satb_array.request
			print("\n--- Accord ", req.index, " (degré ", req.degree_number, ") ---")
			
			if satb_array.satb_objects.size() > 0:
				var best = satb_array.satb_objects[0]
				print("  Meilleur SATB: ", best.satb_notes_name)
				print("  Score: ", best.score)
				print("  Tension: ", best.tension)
				print("  Inversion: ", best.inversion)
				print("  Check notes: ", best.check_notes)
	
	# Accord simple (Dictionary)
	elif response.has("satb_objects"):
		print("Accord résolu, ", response.satb_objects.size(), " voicings")
		if response.satb_objects.size() > 0:
			var best = response.satb_objects[0]
			print("  Meilleur: ", best.satb_notes_name, " (score: ", best.score, ")")

func _on_satb_error(error_code, context):
	print("Erreur API: ", error_code)
	print("Context: ", context)
"""
