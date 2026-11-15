
class_name SpacecraftManager
extends RefCounted

# SPACE VAULT - SPACECRAFT MANAGER
# Godot 4.7
#
# Spacecraft begins with no equipped components.
# All engineering statistics come from equipped parts.

signal spacecraft_updated(stats: Dictionary)

const MAX_BUDGET: float = 1000.0

const CATEGORIES: Array[String] = [
	"engine",
	"battery",
	"solar",
	"scanner",
	"communication",
    "fuel"
]

var database: ComponentDatabase

var equipped_components: Dictionary = {
	"engine": "",
	"battery": "",
	"solar": "",
	"scanner": "",
	"communication": "",
	"fuel": ""
}


func _init() -> void:
	database = ComponentDatabase.new()


func equip_component(component_id: String) -> bool:
	var component: Dictionary = (
		database.get_component(component_id)
	)

	if component.is_empty():
		push_warning(
			"Unknown component: " + component_id
		)
		return false

	var category: String = str(
		component.get("category", "")
	)

	if not equipped_components.has(category):
		push_warning(
			"Unknown component category: " + category
		)
		return false

	equipped_components[category] = component_id

	spacecraft_updated.emit(get_ship_stats())

	return true


func unequip_component(category: String) -> bool:
	if not equipped_components.has(category):
		return false

	equipped_components[category] = ""

	spacecraft_updated.emit(get_ship_stats())

	return true


func clear_equipment() -> void:
	for category in CATEGORIES:
		equipped_components[category] = ""

	spacecraft_updated.emit(get_ship_stats())


func get_equipped_component(
	category: String
) -> String:
	return str(
		equipped_components.get(category, "")
	)


func get_equipped_components() -> Dictionary:
	return equipped_components.duplicate(true)


func get_equipped_count() -> int:
	var count: int = 0

	for category in CATEGORIES:
		if not get_equipped_component(
			category
		).is_empty():
			count += 1

	return count


func get_missing_categories() -> Array[String]:
	var missing: Array[String] = []

	for category in CATEGORIES:
		if get_equipped_component(
			category
		).is_empty():
			missing.append(category)

	return missing


func is_ship_complete() -> bool:
	return get_missing_categories().is_empty()


func get_ship_stats() -> Dictionary:
	# All component statistics start at zero.
	var stats: Dictionary = {
		"mass_kg": 0.0,
		"power_w": 0.0,
		"cost_credits": 0.0,
		"battery_wh": 0.0,
		"solar_generation_w": 0.0,
		"science_score": 0.0,
		"science_data_mb_per_min": 0.0,
		"downlink_mb_per_min": 0.0,
		"data_storage_mb": 0.0,
		"propellant_kg": 0.0,
		"thrust_kn": 0.0,
		"budget_remaining": MAX_BUDGET,
		"within_budget": true,
		"equipped_count": 0,
		"total_slots": CATEGORIES.size(),
		"complete": false,
		"missing_categories": []
	}

	var summed_keys: Array[String] = [
		"mass_kg",
		"power_w",
		"cost_credits",
		"battery_wh",
		"solar_generation_w",
		"science_score",
		"science_data_mb_per_min",
		"downlink_mb_per_min",
		"data_storage_mb",
		"propellant_kg",
        "thrust_kn"
	]

	for category in CATEGORIES:
		var component_id: String = (
			get_equipped_component(category)
		)

		if component_id.is_empty():
			continue

		var component: Dictionary = (
			database.get_component(component_id)
		)

		if component.is_empty():
			continue

		for key in summed_keys:
			stats[key] = (
				float(stats[key])
				+ float(component.get(key, 0.0))
			)

	# Data storage is treated as an optional system
	# capacity provided by components or later upgrades.
	stats["budget_remaining"] = (
		MAX_BUDGET
		- float(stats["cost_credits"])
	)

	stats["within_budget"] = (
		float(stats["cost_credits"])
		<= MAX_BUDGET
	)

	stats["equipped_count"] = (
		get_equipped_count()
	)

	stats["missing_categories"] = (
		get_missing_categories()
	)

	stats["complete"] = (
		is_ship_complete()
	)

	return stats
