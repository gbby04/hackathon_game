
class_name MissionSimulation
extends RefCounted

# SPACE VAULT - ENGINEERING SIMULATIONS
# Godot 4.7
#
# Simplified educational calculations.
# Component specifications and challenge thresholds
# are fictional gameplay parameters.
#
# Earth's gravity: approximately 9.82 m/s^2.
# NASA Earth Fact Sheet reference.

# NASA values are loaded from res://data/nasa_sources.json via NASAData.
# The thrust-to-weight threshold remains a fictional gameplay rule.
const MIN_THRUST_TO_WEIGHT: float = 1.2

var nasa_reference: NASAData = NASAData.new()


func _failed(
	message: String
) -> Dictionary:
	return {
		"valid": true,
		"success": false,
		"explanation": message
	}


func check_eclipse(
	stats: Dictionary,
	duration_minutes: float = 35.0
) -> Dictionary:
	var battery_wh: float = float(
		stats.get("battery_wh", 0.0)
	)

	var power_w: float = float(
		stats.get("power_w", 0.0)
	)

	if battery_wh <= 0.0:
		return {
			"valid": true,
			"success": false,
			"battery_percentage": 0.0,
			"energy_required_wh": 0.0,
			"battery_remaining_wh": 0.0,
			"explanation":
                "MATCHA: No battery equipped. "
				+ "Install a battery before testing the eclipse."
		}

	if power_w <= 0.0:
		return {
			"valid": true,
			"success": false,
			"battery_percentage": 100.0,
			"energy_required_wh": 0.0,
			"battery_remaining_wh": battery_wh,
			"explanation":
                "MATCHA: No powered systems are installed. "
				+ "Install equipment before the test."
		}

	if duration_minutes <= 0.0:
		return {
			"valid": false,
			"success": false,
			"explanation": "Invalid eclipse duration."
		}

	var required_wh: float = (
		power_w * duration_minutes / 60.0
	)

	# Solar generation is unavailable during eclipse.
	var remaining_wh: float = (
		battery_wh - required_wh
	)

	var success: bool = remaining_wh >= 0.0

	var remaining_percentage: float = clampf(
		remaining_wh / battery_wh * 100.0,
		0.0,
		100.0
	)

	var explanation: String = ""

	if success:
		explanation = (
            "Eclipse survived! %.1f Wh used, "
			+ "%.1f Wh remaining."
		) % [
			required_wh,
			remaining_wh
		]
	else:
		explanation = (
            "Battery depleted during eclipse! "
			+ "Need %.1f Wh, have %.1f Wh."
		) % [
			required_wh,
			battery_wh
		]

	return {
		"valid": true,
		"success": success,
		"duration_minutes": duration_minutes,
		"power_w": power_w,
		"energy_required_wh": required_wh,
		"battery_remaining_wh": remaining_wh,
		"battery_percentage": remaining_percentage,
		"explanation": explanation
	}


func check_launch(
	stats: Dictionary,
	mass_limit_kg: float = 500.0
) -> Dictionary:
	var mass_kg: float = float(
		stats.get("mass_kg", 0.0)
	)

	var thrust_kn: float = float(
		stats.get("thrust_kn", 0.0)
	)

	var fuel_kg: float = float(
		stats.get("propellant_kg", 0.0)
	)

	var cost: float = float(
		stats.get("cost_credits", 0.0)
	)

	var budget_ok: bool = bool(
		stats.get("within_budget", false)
	)

	if mass_kg <= 0.0:
		return _failed(
            "MATCHA: The spacecraft has no mass. "
			+ "Equip rocket components first."
		)

	if thrust_kn <= 0.0:
		return _failed(
            "MATCHA: No engine installed. "
			+ "The rocket cannot launch."
		)

	if fuel_kg <= 0.0:
		return _failed(
            "MATCHA: No propellant available. "
			+ "Install a fuel tank."
		)

	if mass_limit_kg <= 0.0:
		return {
			"valid": false,
			"success": false,
			"explanation": "Invalid launch mass limit."
		}

	if not nasa_reference.loaded:
		return {
			"valid": false,
			"success": false,
			"explanation": "NASA dataset could not be loaded."
		}

	var earth_gravity: float = nasa_reference.get_surface_gravity()

	if earth_gravity <= 0.0:
		return {
			"valid": false,
			"success": false,
			"explanation": "NASA Earth gravity reference unavailable."
		}

	var weight_newtons: float = (
		mass_kg * earth_gravity
	)

	var thrust_newtons: float = (
		thrust_kn * 1000.0
	)

	var thrust_to_weight: float = (
		thrust_newtons / weight_newtons
	)

	var mass_ok: bool = (
		mass_kg <= mass_limit_kg
	)

	var thrust_ok: bool = (
		thrust_to_weight >= MIN_THRUST_TO_WEIGHT
	)

	var success: bool = (
		mass_ok and thrust_ok and budget_ok
	)

	var explanation: String = ""

	if success:
		explanation = (
            "Launch check passed! Mass %.1f kg, "
			+ "thrust-to-weight %.2f."
		) % [
			mass_kg,
			thrust_to_weight
		]
	else:
		var reasons: Array[String] = []

		if not mass_ok:
			reasons.append("Mass exceeds launch limit")

		if not thrust_ok:
			reasons.append("Insufficient thrust")

		if not budget_ok:
			reasons.append("Over budget")

		explanation = "; ".join(reasons) + "."

	return {
		"valid": true,
		"success": success,
		"mass_kg": mass_kg,
		"mass_limit_kg": mass_limit_kg,
		"thrust_kn": thrust_kn,
		"thrust_to_weight": thrust_to_weight,
		"earth_gravity_m_s2": earth_gravity,
		"earth_gravity_source": "nasa_earth",
		"propellant_kg": fuel_kg,
		"cost_credits": cost,
		"within_budget": budget_ok,
		"explanation": explanation
	}


func check_communications(
	stats: Dictionary,
	observation_minutes: float = 20.0,
	contact_minutes: float = 6.0,
	required_data_mb: float = 15.0
) -> Dictionary:
	var data_rate: float = float(
		stats.get("science_data_mb_per_min", 0.0)
	)

	var downlink_rate: float = float(
		stats.get("downlink_mb_per_min", 0.0)
	)

	var storage_mb: float = float(
		stats.get("data_storage_mb", 0.0)
	)

	if data_rate <= 0.0:
		return _failed(
            "MATCHA: No science instrument installed. "
			+ "There is no data to transmit."
		)

	if downlink_rate <= 0.0:
		return _failed(
            "MATCHA: No communication module installed. "
			+ "Data cannot be transmitted."
		)

	if (
		observation_minutes <= 0.0
		or contact_minutes <= 0.0
		or required_data_mb <= 0.0
	):
		return {
			"valid": false,
			"success": false,
			"explanation": "Invalid communications test settings."
		}

	var generated_mb: float = (
		data_rate * observation_minutes
	)

	# In this simplified prototype, zero storage
	# means there is no separately specified storage
	# limit. The camera buffers its generated data.
	var stored_mb: float = generated_mb

	if storage_mb > 0.0:
		stored_mb = minf(
			generated_mb,
			storage_mb
		)

	var transmitted_mb: float = minf(
		stored_mb,
		downlink_rate * contact_minutes
	)

	var success: bool = (
		transmitted_mb >= required_data_mb
	)

	var explanation: String = ""

	if success:
		explanation = (
            "Transmission successful! "
			+ "%.1f MB delivered."
		) % transmitted_mb
	else:
		explanation = (
            "Insufficient downlink! "
			+ "%.1f MB delivered; %.1f MB required."
		) % [
			transmitted_mb,
			required_data_mb
		]

	return {
		"valid": true,
		"success": success,
		"generated_data_mb": generated_mb,
		"stored_data_mb": stored_mb,
		"transmitted_data_mb": transmitted_mb,
		"required_data_mb": required_data_mb,
		"contact_minutes": contact_minutes,
		"explanation": explanation
	}


func evaluate_mission(
	stats: Dictionary
) -> Dictionary:
	var count: int = int(
		stats.get("equipped_count", 0)
	)

	if count < 6:
		return {
			"valid": true,
			"success": false,
			"explanation":
                "MATCHA: Spacecraft incomplete. "
				+ "Equip all six component categories.",
			"equipped_count": count
		}

	var eclipse: Dictionary = (
		check_eclipse(stats, 35.0)
	)

	var launch: Dictionary = (
		check_launch(stats, 500.0)
	)

	var communications: Dictionary = (
		check_communications(
			stats,
			20.0,
			6.0,
			15.0
		)
	)

	var success: bool = (
		bool(eclipse.get("success", false))
		and bool(launch.get("success", false))
		and bool(communications.get("success", false))
	)

	return {
		"valid": true,
		"success": success,
		"eclipse": eclipse,
		"launch": launch,
		"communications": communications,
		"explanation": (
            "All engineering readiness checks passed!"
			if success
			else "One or more engineering checks failed."
		)
	}
