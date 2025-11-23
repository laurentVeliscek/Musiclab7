# ModulationManager.gd
# =====================
# Gestionnaire de modulations pour Godot 3.6
# Utilise la bibliothèque v2.3.2 avec support de la modulation chromatique

extends Resource
class_name ModulationManager

# ============================================================================
# VARIABLES
# ============================================================================

var modulation_db = {}
var current_key = 0  # 0 = C, 1 = C#, etc.
var current_mode = "major"
var TAG = "ModulationManager"
# Notes MIDI (pour référence)
const NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

# ============================================================================
# INITIALISATION
# ============================================================================

func _ready():
	load_modulation_database()
	#print("🎵 ModulationManager prêt !")
	#print("   Tonalité actuelle : ", get_current_key_name(), " ", current_mode)

func load_modulation_database():
	"""Charge la bibliothèque de modulations depuis le fichier JSON"""
	var file = File.new()
	var path = "res://addons/musiclib/modulation/modulationDB.json"
	
	if not file.file_exists(path):
		LogBus.error(TAG,"❌ Fichier de modulation introuvable : " + path)
		return
	
	file.open(path, File.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse(json_text)
	if parse_result.error != OK:
		LogBus.error(TAG,"❌ Erreur de parsing JSON : " + str(parse_result.error))
		return
	
	modulation_db = parse_result.result
	
	print("modulation_db.size(): "+ str(modulation_db.size()))
	
	LogBus.info(TAG,"ModulationManager loaded :")
	#LogBus.info(TAG,"Version: " +  str(modulation_db["version"]))
	#LogBus.info(TAG,"Progressions: " +  str(modulation_db["metadata"]["total_progressions"]))
	#LogBus.info(TAG,"Techniques : " +  str(modulation_db["metadata"]["techniques_available"]))

# ============================================================================
# GETTERS
# ============================================================================

#func get_current_key_name() -> String:
#	"""Retourne le nom de la tonalité actuelle"""
#	return NOTE_NAMES[current_key]

func get_technique_count() -> Dictionary:
	"""Retourne le nombre de progressions par technique"""
	var counts = {
		"chromatic": 0,
		"pivot_chord": 0,
		"secondary_dominant": 0
	}
	
	for prog in modulation_db["progressions"]:
		if prog["technique"] in counts:
			counts[prog["technique"]] += 1
	
	return counts

# ============================================================================
# REQUÊTES DE MODULATION
# ============================================================================
#
#func get_modulation(to_key: int, technique: String = "", filters: Dictionary = {}) -> Dictionary:
#	"""
#	Trouve une modulation de la tonalité actuelle vers une nouvelle tonalité
#
#	Args:
#		to_key: Tonalité cible (0-11, où 0=C)
#		technique: "chromatic", "pivot_chord", "secondary_dominant", ou "" pour auto
#		filters: Dictionnaire de filtres optionnels
#			- min_quality: float (0.0-1.0)
#			- max_length: int
#			- to_mode: "major" ou "minor"
#			- style: Array (ex: ["jazz", "classical"])
#
#	Returns:
#		Dictionnaire avec la progression (ou {} si non trouvée)
#	"""
#	var offset = (to_key - current_key) % 12
#
#	if offset == 0:
#		push_warning("⚠️ Pas de modulation nécessaire (même tonalité)")
#		return {}
#
#	var candidates = []
#
#	for prog in modulation_db["progressions"]:
#		# Filtre de base : offset et mode source
#		if prog["offset"] != offset:
#			continue
#		if prog["from_mode"] != current_mode:
#			continue
#
#		# Filtre technique
#		if technique != "" and prog["technique"] != technique:
#			continue
#
#		# Filtres optionnels
#		if filters.has("min_quality") and prog["quality"]["overall"] < filters["min_quality"]:
#			continue
#
#		if filters.has("max_length") and prog["metadata"]["length"] > filters["max_length"]:
#			continue
#
#		if filters.has("to_mode") and prog["to_mode"] != filters["to_mode"]:
#			continue
#
#		if filters.has("style"):
#			var has_style = false
#			for s in filters["style"]:
#				if s in prog["metadata"]["style"]:
#					has_style = true
#					break
#			if not has_style:
#				continue
#
#		candidates.append(prog)
#
#	# Trier par qualité (meilleur en premier)
#	candidates.sort_custom(self, "_sort_by_quality")
#
#	if candidates.size() > 0:
#		return candidates[0]
#	else:
#		push_warning("⚠️ Aucune modulation trouvée pour offset " + str(offset))
#		return {}
#
#

func get_all_modulations(from_key:int,from_mode:String, to_key: int, to_mode:String) -> Array:
	"""
	Retourne TOUTES les progressions possibles vers une tonalité
	Utile pour comparer différentes techniques
	"""
	
	current_key = from_key % 12
	current_mode = from_mode
	
	var offset = (12 + to_key - from_key) % 12
	var results = []
	
	#for prog in modulation_db["progressions"]:
	for prog in modulation_db:
		if prog["to_root"] == offset and prog["from_mode"] == from_mode and prog["to_mode"] == to_mode:
			#if prog["id"]== 1:
			results.append(prog)
	
#	results.sort_custom(self, "_sort_by_quality")
	return results

#func _sort_by_quality(a, b):
#	"""Helper pour trier par qualité"""
#	return a["quality"]["overall"] > b["quality"]["overall"]

# ============================================================================
# RECOMMANDATIONS INTELLIGENTES
# ============================================================================
#
#func get_best_technique_for_offset(offset: int) -> String:
#	"""
#	Recommande la meilleure technique pour un offset donné
#
#	Basé sur les principes théoriques :
#	- Offsets 1, 2, 10, 11 : Chromatique (optimal)
#	- Offsets 3, 4, 8, 9 : Chromatique ou Secondary
#	- Offset 7 : Secondary ou Pivot (quinte)
#	- Offset 5 : Secondary ou Pivot (quarte)
#	"""
#	match offset:
#		1, 2, 10, 11:
#			return "chromatic"  # Modulations par demi-ton/ton
#		3, 4, 8, 9:
#			return "chromatic"  # Tierces/sixtes - chromatique excellent
#		7:
#			return "secondary_dominant"  # Quinte - secondary classique
#		5:
#			return "pivot_chord"  # Quarte - pivot traditionnel
#		6:
#			return "secondary_dominant"  # Triton - secondary
#		_:
#			return ""
##
#func suggest_modulation(to_key: int) -> Dictionary:
#	"""
#	Suggère la meilleure modulation en utilisant la technique optimale
#	"""
#	var offset = (to_key - current_key) % 12
#	var recommended_technique = get_best_technique_for_offset(offset)
#
#	print("💡 Technique recommandée pour offset ", offset, " : ", recommended_technique)
#
#	return get_modulation(to_key, recommended_technique)
#
## ============================================================================
## AFFICHAGE ET DEBUG
## ============================================================================
#
#func print_progression(prog: Dictionary):
#	"""Affiche une progression de manière lisible"""
#	if prog.empty():
#		print("❌ Progression vide")
#		return
#
#	print("🎵 Progression #", prog["id"])
#	print("   Offset: +", prog["offset"])
#	print("   Technique: ", prog["technique"])
#	print("   Quality: ", prog["quality"]["overall"])
#	print("   Difficulty: ", prog["metadata"]["difficulty"], "/5")
#	print("   Character: ", prog["metadata"]["character"])
#	print("   Length: ", prog["metadata"]["length"], " accords")
#
#	if prog["metadata"]["warnings"].size() > 0:
#		print("   ⚠️  Warnings: ", prog["metadata"]["warnings"])
#
#	print("\n   Accords:")
#	for i in range(prog["chords"].size()):
#		var chord = prog["chords"][i]
#		var chord_str = format_chord(chord)
#		print("   ", i+1, ". ", chord_str)
#		if chord.has("comment"):
#			print("      → ", chord["comment"])
#
#func format_chord(chord: Dictionary) -> String:
#	"""Formate un accord pour l'affichage"""
#	var key_name = NOTE_NAMES[chord["key_midi_root"]]
#	var mode = chord["key_scale_name"]
#	var degree = chord["degree_number"]
#	var seventh = "7" if chord["seventh"] else ""
#	var inv = " (inv" + str(chord["inversion"]) + ")" if chord["inversion"] > 0 else ""
#
#	return "deg" + str(degree) + seventh + " in " + key_name + " " + mode + inv
#
## ============================================================================
## CHANGEMENT DE TONALITÉ
## ============================================================================
#
#func modulate_to(to_key: int, technique: String = ""):
#	"""
#	Effectue une modulation vers une nouvelle tonalité
#	Met à jour current_key
#	"""
#	var from_name = get_current_key_name()
#	var to_name = NOTE_NAMES[to_key]
#
#	print("\n🎼 Modulation : ", from_name, " ", current_mode, " → ", to_name)
#
#	var prog = get_modulation(to_key, technique)
#
#	if prog.empty():
#		push_error("❌ Impossible de moduler vers " + to_name)
#		return
#
#	print_progression(prog)
#
#	# Mettre à jour la tonalité actuelle
#	current_key = to_key
#	current_mode = prog["to_mode"]
#
#	print("\n✓ Modulation réussie ! Nouvelle tonalité : ", get_current_key_name(), " ", current_mode)
#
## ============================================================================
## EXEMPLES D'UTILISATION
## ============================================================================
#
#func example_basic_modulation():
#	"""Exemple : Modulation simple de C à G"""
#	print("\n" + "=".repeat(70))
#	print("📌 EXEMPLE 1 : Modulation basique C → G")
#	print("=".repeat(70))
#
#	current_key = 0  # C
#	current_mode = "major"
#
#	modulate_to(7)  # G
#
#func example_chromatic_modulation():
#	"""Exemple : Modulation chromatique C → Db"""
#	print("\n" + "=".repeat(70))
#	print("📌 EXEMPLE 2 : Modulation chromatique C → Db")
#	print("=".repeat(70))
#
#	current_key = 0  # C
#	current_mode = "major"
#
#	modulate_to(1, "chromatic")  # Db
#
#
#func example_advanced_filtering():
#	"""Exemple : Filtrage avancé"""
#	print("\n" + "=".repeat(70))
#	print("📌 EXEMPLE 4 : Filtrage avancé")
#	print("=".repeat(70))
#
#	current_key = 0  # C
#	current_mode = "major"
#
#	var filters = {
#		"min_quality": 0.95,
#		"max_length": 5,
#		"style": ["romantic"]
#	}
#
#	var prog = get_modulation(5, "", filters)  # F
#
#	if not prog.empty():
#		print("✓ Progression trouvée avec filtres :")
#		print_progression(prog)
#	else:
#		print("❌ Aucune progression correspondant aux filtres")
#
## ============================================================================
## TESTS (appeler depuis _ready() ou un autre node)
## ============================================================================
#
#func run_all_examples():
#	"""Lance tous les exemples"""
#	example_basic_modulation()
#	example_chromatic_modulation()
#	example_advanced_filtering()
#
## ============================================================================
## NOTES D'UTILISATION
## ============================================================================
#
#"""
#UTILISATION DANS VOTRE JEU :
#
#1. Attachez ce script à un node singleton ou autoload :
#   Project Settings > AutoLoad > Add : ModulationManager.gd
#
#2. Dans n'importe quel script :
#
#   # Moduler vers une nouvelle tonalité
#   ModulationManager.modulate_to(7)  # Vers G
#
#   # Obtenir une progression sans changer de tonalité
#   var prog = ModulationManager.get_modulation(5, "chromatic")
#
#   # Comparer toutes les techniques
#   var all_progs = ModulationManager.get_all_modulations(2)
#
#   # Utiliser la technique recommandée
#   var best_prog = ModulationManager.suggest_modulation(1)
#
#3. Intégrer avec votre système musical :
#
#   func play_modulation(prog: Dictionary):
#	   for chord in prog["chords"]:
#		   var notes = get_chord_notes(chord)
#		   play_notes(notes)
#		   yield(get_tree().create_timer(1.0), "timeout")
#
#ASTUCES :
#
#- La technique "chromatic" est excellente pour des transitions douces
#- Utilisez suggest_modulation() pour obtenir la meilleure technique automatiquement
#- Filtrez par "style" si vous avez un genre musical spécifique
#- Les progressions sont triées par qualité, prenez la première !
#"""
