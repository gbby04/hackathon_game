
class_name SpacecraftManager
extends RefCounted

signal spacecraft_updated(stats: Dictionary)

const BASE_STRUCTURE_MASS_KG = 120.0
const BASE_SYSTEM_POWER_W = 40.0
const BASE_STRUCTURE_COST = 100.0
const BASE_DATA_STORAGE_MB = 200.0

const MAX_BUDGET = 1000.0

var database: ComponentDatabase

var equipped_components: Dictionary = {
	"engine": "engine_basic",
	"battery": "battery_standard",
	"solar": "solar_small",
	"scanner": "scanner_basic",
	"communication": "comm_basic",
	"fuel": "fuel_small"
}


func _init() -> void:
	database = ComponentDatabase.new()


func equip_component(component_id: String) -> bool:
	if not database.has_component(component_id):
		push_warning("Cannot equip unknown component.")
		return false

	var component := database.get_component(component_id)
	var category := str(component.get("category", ""))

	if not equipped_components.has(category):
		push_warning("Unsupported category: " + category)
		return false

	equipped_components[category] = component_id

	spacecraft_updated.emit(get_ship_stats())

	print("Equipped: ", component.get("name", component_id))

	return true


func get_equipped_component(category: String) -> Dictionary:
	if not equipped_components.has(category):
		return {}

	var component_id := str(equipped_components[category])

	return database.get_component(component_id)


func get_ship_stats() -> Dictionary:
	var total_mass := BASE_STRUCTURE_MASS_KG
	var total_power := BASE_SYSTEM_POWER_W
	var total_cost := BASE_STRUCTURE_COST

	var battery_capacity := 0.0
	var solar_generation := 0.0
	var science_score := 0.0
	var science_data_rate := 0.0
	var downlink_rate := 0.0
	var propellant_mass := 0.0
	var engine_thrust := 0.0

	for category in equipped_components:
		var component := get_equipped_component(category)

		if component.is_empty():
			continue

		total_mass += float(component.get("mass_kg", 0))
		total_power += float(component.get("power_w", 0))
		total_cost += float(component.get("cost_credits", 0))

		battery_capacity += float(
			component.get("battery_wh", 0)
		)

		solar_generation += float(
			component.get("solar_generation_w", 0)
		)

		science_score += float(
			component.get("science_score", 0)
		)

		science_data_rate += float(
			component.get("data_mb_per_min", 0)
		)

		downlink_rate += float(
			component.get("downlink_mb_per_min", 0)
		)

		propellant_mass += float(
			component.get("propellant_kg", 0)
		)

		engine_thrust += float(
			component.get("thrust_kn", 0)
		)

	var remaining_budget := MAX_BUDGET - total_cost

	return {
		"mass_kg": total_mass,
		"power_w": total_power,
		"cost_credits": total_cost,
		"budget_remaining": remaining_budget,
		"battery_wh": battery_capacity,
		"solar_generation_w": solar_generation,
		"science_score": science_score,
		"science_data_mb_per_min": science_data_rate,
		"downlink_mb_per_min": downlink_rate,
		"data_storage_mb": BASE_DATA_STORAGE_MB,
		"propellant_kg": propellant_mass,
		"thrust_kn": engine_thrust,
		"within_budget": total_cost <= MAX_BUDGET
	}


func print_ship_stats() -> void:
	var stats := get_ship_stats()

	print("")
	print("===================================")
	print("       SPACE VAULT SHIP STATS      ")
	print("===================================")

	print("Total Mass: ", stats["mass_kg"], " kg")
	print("Power Consumption: ", stats["power_w"], " W")
	print("Battery: ", stats["battery_wh"], " Wh")
	print("Solar Generation: ", stats["solar_generation_w"], " W")
	print("Total Cost: ", stats["cost_credits"], " credits")
	print("Budget Remaining: ", stats["budget_remaining"])
	print("Science Score: ", stats["science_score"])
	print("Science Data: ", stats["science_data_mb_per_min"], " MB/min")
	print("Downlink: ", stats["downlink_mb_per_min"], " MB/min")
	print("Data Storage: ", stats["data_storage_mb"], " MB")
	print("Propellant: ", stats["propellant_kg"], " kg")
	print("Engine Thrust: ", stats["thrust_kn"], " kN")
	print("Within Budget: ", stats["within_budget"])

	print("===================================")
	print("")
