
class_name NASAData
extends RefCounted

# SPACE VAULT - NASA REFERENCE DATABASE
# Godot 4.7 - Member 2

const DATA_PATH: String = "res://data/nasa_sources.json"

var sources: Dictionary = {}
var game_assumptions: Dictionary = {}
var loaded: bool = false


func _init() -> void:
	load_data()


func load_data() -> bool:
	sources.clear()
	game_assumptions.clear()
	loaded = false

	if not FileAccess.file_exists(DATA_PATH):
		push_error("NASA data file missing: " + DATA_PATH)
		return false

	var file: FileAccess = FileAccess.open(
		DATA_PATH,
		FileAccess.READ
	)

	if file == null:
		push_error("Cannot open NASA data file.")
		return false

	var contents: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var error_code: Error = json.parse(contents)

	if error_code != OK:
		push_error(
			"NASA JSON error at line %d: %s" % [
				json.get_error_line(),
				json.get_error_message()
			]
		)
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("NASA data root must be an object.")
		return false

	var data: Dictionary = json.data

	var source_list: Variant = data.get("sources", [])

	if typeof(source_list) != TYPE_ARRAY:
		push_error("NASA sources must be an array.")
		return false

	for item in source_list:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var source: Dictionary = item
		var source_id: String = str(
			source.get("id", "")
		)

		if source_id.is_empty():
			continue

		sources[source_id] = source.duplicate(true)

	var assumptions: Variant = data.get(
		"game_assumptions",
		{}
	)

	if typeof(assumptions) == TYPE_DICTIONARY:
		game_assumptions = assumptions.duplicate(true)

	loaded = sources.has("nasa_earth")

	if not loaded:
		push_error("NASA Earth reference is missing.")
		return false

	print("NASA reference database loaded.")
	print("NASA sources: ", sources.size())

	return true


func get_source(source_id: String) -> Dictionary:
	if sources.has(source_id):
		return sources[source_id].duplicate(true)

	return {}


func get_earth_value(
	parameter: String,
	fallback: float = 0.0
) -> float:

	var earth: Dictionary = get_source("nasa_earth")
	var values: Dictionary = earth.get("values", {})

	return float(values.get(parameter, fallback))


func get_surface_gravity() -> float:
	return get_earth_value(
		"surface_gravity_m_s2",
		9.82
	)


func get_escape_velocity() -> float:
	return get_earth_value(
		"escape_velocity_km_s",
		11.186
	)


func get_earth_radius() -> float:
	return get_earth_value(
		"mean_radius_km",
		6371.0
	)


func get_solar_irradiance() -> float:
	return get_earth_value(
		"solar_irradiance_w_m2",
		1361.0
	)


func print_nasa_data() -> void:
	print("")
	print("===================================")
	print("NASA REFERENCE DATA")
	print("===================================")

	print("Earth gravity: ", get_surface_gravity(), " m/s^2")
	print("Escape velocity: ", get_escape_velocity(), " km/s")
	print("Mean Earth radius: ", get_earth_radius(), " km")
	print("Solar irradiance: ", get_solar_irradiance(), " W/m^2")

	var earth: Dictionary = get_source("nasa_earth")

	print("Source: ", earth.get("title", "Unknown"))
	print("URL: ", earth.get("url", "Unknown"))
	print("===================================")
