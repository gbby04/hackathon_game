
extends Control

# SPACE VAULT - SIMULATION TEST
# Member 2 - Godot 4.7

var spacecraft: SpacecraftManager
var simulator: MissionSimulation


func _ready() -> void:
	spacecraft = SpacecraftManager.new()
	simulator = MissionSimulation.new()

	if not spacecraft.database.loaded:
		push_error("Component database failed to load.")
		return

	print("")
	print("======================================")
	print("SPACE VAULT - ENGINEERING TESTS")
	print("======================================")

	test_eclipse()
	test_launch()
	test_communications()
	test_full_mission()

	print("")
	print("ALL ENGINEERING TESTS PASSED!")


func test_eclipse() -> void:
	print("")
	print("TEST 1 - DR. WATT")

	var stats: Dictionary = spacecraft.get_ship_stats()
	var result: Dictionary = simulator.check_eclipse(stats)

	print(result["explanation"])
	print("Energy needed: ", result["energy_needed_wh"], " Wh")
	print("Battery remaining: ", result["remaining_wh"], " Wh")

	assert(
		result["success"] == true,
        "Default ship should survive the eclipse."
	)

	# Upgrade to high-power equipment.
	spacecraft.equip_component("scanner_advanced")
	spacecraft.equip_component("comm_advanced")

	stats = spacecraft.get_ship_stats()
	result = simulator.check_eclipse(stats)

	print("High-power configuration:")
	print(result["explanation"])

	assert(
		result["success"] == false,
        "High-power ship should fail with small battery."
	)

	# Upgrade battery.
	spacecraft.equip_component("battery_large")

	stats = spacecraft.get_ship_stats()
	result = simulator.check_eclipse(stats)

	print("After battery upgrade:")
	print(result["explanation"])

	assert(
		result["success"] == true,
        "Large battery should survive the eclipse."
	)


func test_launch() -> void:
	print("")
	print("TEST 2 - DR. DELTA-V")

	var stats: Dictionary = spacecraft.get_ship_stats()
	var result: Dictionary = simulator.check_launch(stats)

	print(result["explanation"])
	print("Mass: ", result["mass_kg"], " kg")
	print("Mass margin: ", result["mass_margin_kg"], " kg")
	print("Thrust-to-weight: ", result["thrust_to_weight"])

	assert(
		result["success"] == true,
        "Current ship should pass the launch checks."
	)

	# Switch to heavier components.
	spacecraft.equip_component("engine_advanced")
	spacecraft.equip_component("fuel_large")

	stats = spacecraft.get_ship_stats()
	result = simulator.check_launch(stats)

	print("Heavy configuration:")
	print(result["explanation"])

	assert(
		result["success"] == false,
        "Heavy ship should fail the mass check."
	)

	# Restore lighter parts for later tests.
	spacecraft.equip_component("engine_basic")
	spacecraft.equip_component("fuel_small")


func test_communications() -> void:
	print("")
	print("TEST 3 - DR. DOWNLINK")

	var stats: Dictionary = spacecraft.get_ship_stats()

	var result: Dictionary = simulator.check_communications(
		stats,
		20.0,
		6.0,
		15.0
	)

	print(result["explanation"])
	print("Data generated: ", result["data_generated_mb"], " MB")
	print("Data returned: ", result["data_returned_mb"], " MB")

	assert(
		result["success"] == true,
        "Expected at least 15 MB returned."
	)

	# Make the scientific requirement harder.
	result = simulator.check_communications(
		stats,
		20.0,
		6.0,
		100.0
	)

	print("Higher science requirement:")
	print(result["explanation"])

	assert(
		result["success"] == false,
        "Expected failure for 100 MB requirement."
	)


func test_full_mission() -> void:
	print("")
	print("TEST 4 - COMPLETE MISSION")

	# Choose a configuration that passes all checks.
	spacecraft.equip_component("scanner_basic")
	spacecraft.equip_component("comm_advanced")
	spacecraft.equip_component("battery_large")

	var stats: Dictionary = spacecraft.get_ship_stats()
	var result: Dictionary = simulator.evaluate_mission(stats)

	print("Mass: ", stats["mass_kg"], " kg")
	print("Power: ", stats["power_w"], " W")
	print("Cost: ", stats["cost_credits"], " credits")

	print("Eclipse passed: ", result["eclipse"]["success"])
	print("Launch passed: ", result["launch"]["success"])
	print(
		"Communications passed: ",
		result["communications"]["success"]
	)

	print(result["explanation"])

	assert(
		result["success"] == true,
        "Expected the final configuration to pass."
	)
