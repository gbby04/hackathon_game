
class_name ComponentDatabase
extends RefCounted

const DATA_PATH = "res://data/components.json"

var components: Dictionary = {}
var dataset_info: Dictionary = {}
var loaded: bool = false


func _init() -> void:
	load_components()


func load_components() -> bool:
	components.clear()
	dataset_info.clear()
	loaded = false

	if not FileAccess.file_exists(DATA_PATH):
		push_error("Missing component file: " + DATA_PATH)
		return false

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)

	if file == null:
		push_error("Cannot open component database.")
		return false

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(json_text)

	if result != OK:
		push_error(
			"JSON error at line %d: %s" %
			[json.get_error_line(), json.get_error_message()]
		)
		return false

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:
		push_error("Component database must be an object.")
		return false

	if not data.has("components"):
		push_error("Missing components array.")
		return false

	if typeof(data["components"]) != TYPE_ARRAY:
		push_error("Components must be an array.")
		return false

	dataset_info = data.duplicate(true)

	for item in data["components"]:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var component_id := str(item.get("id", ""))

		if component_id.is_empty():
			push_warning("Skipped component without ID.")
			continue

		components[component_id] = item.duplicate(true)

	loaded = true

	print("Component database loaded.")
	print("Total components: ", components.size())

	return true


func get_component(component_id: String) -> Dictionary:
	if components.has(component_id):
		return components[component_id].duplicate(true)

	push_warning("Component not found: " + component_id)
	return {}


func has_component(component_id: String) -> bool:
	return components.has(component_id)


func get_all_components() -> Array:
	var result: Array = []

	for component in components.values():
		result.append(component.duplicate(true))

	return result


func get_components_by_category(category: String) -> Array:
	var result: Array = []

	for component in components.values():
		if str(component.get("category", "")) == category:
			result.append(component.duplicate(true))

	return result


func get_component_count() -> int:
	return components.size()
