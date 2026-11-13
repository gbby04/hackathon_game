
extends Node

# SPACE VAULT - SHARED SPACECRAFT GAME STATE
# Godot 4.7
# Member 2
#
# This script will be registered as an Autoload
# with the name SpacecraftGameState.

signal equipment_changed(stats: Dictionary)
signal inventory_changed

var spacecraft: SpacecraftManager
var simulator: MissionSimulation

var unlocked_components: Array[String] = []

# Standalone development setting:
# All 12 parts are available for testing.
# The team's final game should change this to false
# when the vault unlocking system is integrated.
var development_unlock_all: bool = true


func _ready() -> void:
	spacecraft = SpacecraftManager.new()
	simulator = MissionSimulation.new()

	if not spacecraft.database.loaded:
		push_error(
            "Spacecraft database could not be loaded."
		)
		return

	spacecraft.spacecraft_updated.connect(
		_on_spacecraft_updated
	)

	if development_unlock_all:
		unlock_all_components()
	else:
		unlock_default_components()

	print("SPACECRAFT GAME STATE READY")


func unlock_default_components() -> void:
	for component_id in spacecraft.equipped_components.values():
		unlock_component(str(component_id))


func unlock_all_components() -> void:
	var components: Array = (
		spacecraft.database.get_all_components()
	)

	for component in components:
		unlock_component(str(component.get("id", "")))


func unlock_component(component_id: String) -> bool:
	if not spacecraft.database.has_component(component_id):
		return false

	if unlocked_components.has(component_id):
		return false

	unlocked_components.append(component_id)

	inventory_changed.emit()

	return true


func is_component_unlocked(component_id: String) -> bool:
	return unlocked_components.has(component_id)


func equip_component(component_id: String) -> bool:
	if not is_component_unlocked(component_id):
		push_warning(
			"Component is locked: " + component_id
		)
		return false

	return spacecraft.equip_component(component_id)


func get_ship_stats() -> Dictionary:
	return spacecraft.get_ship_stats()


func get_equipped_component(category: String) -> Dictionary:
	return spacecraft.get_equipped_component(category)


func get_available_components(category: String) -> Array:
	var result: Array = []

	var components: Array = (
		spacecraft.database.get_components_by_category(
			category
		)
	)

	for component in components:
		var id: String = str(component.get("id", ""))

		if is_component_unlocked(id):
			result.append(component)

	return result


# DR. WATT
func check_eclipse(
	duration_minutes: float = 35.0
) -> Dictionary:

	return simulator.check_eclipse(
		get_ship_stats(),
		duration_minutes
	)


# DR. DELTA-V
func check_launch(
	mass_limit_kg: float = 500.0
) -> Dictionary:

	return simulator.check_launch(
		get_ship_stats(),
		mass_limit_kg
	)


# DR. DOWNLINK
func check_communications(
	observation_minutes: float = 20.0,
	contact_minutes: float = 6.0,
	required_data_mb: float = 15.0
) -> Dictionary:

	return simulator.check_communications(
		get_ship_stats(),
		observation_minutes,
		contact_minutes,
		required_data_mb
	)


# COMPLETE MISSION
func evaluate_mission() -> Dictionary:
	return simulator.evaluate_mission(
		get_ship_stats()
	)


func _on_spacecraft_updated(stats: Dictionary) -> void:
	equipment_changed.emit(stats)
