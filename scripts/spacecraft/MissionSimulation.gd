
class_name MissionSimulation
extends RefCounted

# SPACE VAULT - ENGINEERING SIMULATION
# Godot 4.7 - Member 2
#
# NASA reference:
# https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html
#
# Other mission parameters are fictional prototype
# values unless identified as source-derived.

const ECLIPSE_DURATION_MIN: float = 35.0
const LAUNCH_MASS_LIMIT_KG: float = 500.0
const MIN_INITIAL_TWR: float = 1.2

const OBSERVATION_DURATION_MIN: float = 20.0
const GROUND_CONTACT_MIN: float = 6.0
const REQUIRED_SCIENCE_DATA_MB: float = 15.0

var nasa: NASAData


func _init() -> void:
	nasa = NASAData.new()


# ==========================================
# DR. WATT - ECLIPSE POWER CHECK
# ==========================================

func check_eclipse(
	stats: Dictionary,
	duration_minutes: float = ECLIPSE_DURATION_MIN
) -> Dictionary:

	if duration_minutes < 0.0:
		return _invalid_result(
            "Invalid eclipse duration."
		)

	var power_w: float = float(
		stats.get("power_w", 0.0)
	)

	var battery_wh: float = float(
		stats.get("battery_wh", 0.0)
	)

	if power_w < 0.0 or battery_wh < 0.0:
		return _invalid_result(
            "Invalid power or battery value."
		)

	# Solar panels provide no power in full eclipse.
	var duration_hours: float = duration_minutes / 60.0

	var energy_needed_wh: float = (
		power_w * duration_hours
	)

	var remaining_wh: float = (
		battery_wh - energy_needed_wh
	)

	var survived: bool = remaining_wh >= 0.0

	var battery_percentage: float = 0.0

	if battery_wh > 0.0:
		battery_percentage = clampf(
			remaining_wh / battery_wh * 100.0,
			0.0,
			100.0
		)

	var explanation: String = ""

	if survived:
		explanation = (
            "B-MO: Our battery survived the eclipse! "
			+ "We still have %.1f Wh remaining."
		) % remaining_wh
	else:
		explanation = (
            "B-MO: SYSTEM BROWNOUT! "
			+ "We need %.1f Wh more energy."
		) % absf(remaining_wh)

	return {
		"success": survived,
		"valid": true,
		"boss": "Dr. Watt",
		"attack": "Solar Eclipse Shadow",
		"duration_min": duration_minutes,
		"power_w": power_w,
		"battery_wh": battery_wh,
		"energy_needed_wh": energy_needed_wh,
		"remaining_wh": remaining_wh,
		"battery_percentage": battery_percentage,
		"explanation": explanation
	}


# ==========================================
# DR. DELTA-V - LAUNCH CHECK
# ==========================================

func check_launch(
	stats: Dictionary,
	mass_limit_kg: float = LAUNCH_MASS_LIMIT_KG
) -> Dictionary:

	if not nasa.loaded:
		return _invalid_result(
            "NASA reference data could not be loaded."
		)

	if mass_limit_kg <= 0.0:
		return _invalid_result(
            "Invalid launch mass limit."
		)

	var mass_kg: float = float(
		stats.get("mass_kg", 0.0)
	)

	var thrust_kn: float = float(
		stats.get("thrust_kn", 0.0)
	)

	var within_budget: bool = bool(
		stats.get("within_budget", false)
	)

	if mass_kg <= 0.0 or thrust_kn < 0.0:
		return _invalid_result(
            "Invalid spacecraft mass or thrust."
		)

	# NASA's Earth Fact Sheet provides 9.82 m/s^2
	# as Earth's mean surface gravity.
	var gravity: float = nasa.get_surface_gravity()

	if gravity <= 0.0:
		return _invalid_result(
            "Invalid NASA gravity reference."
		)

	var mass_margin_kg: float = (
		mass_limit_kg - mass_kg
	)

	var within_mass_limit: bool = (
		mass_margin_kg >= 0.0
	)

	# Convert kilonewtons to newtons.
	var thrust_n: float = thrust_kn * 1000.0

	var weight_n: float = (
		mass_kg * gravity
	)

	var thrust_to_weight: float = (
		thrust_n / weight_n
	)

	var enough_thrust: bool = (
		thrust_to_weight >= MIN_INITIAL_TWR
	)

	var passed: bool = (
		within_mass_limit
		and enough_thrust
		and within_budget
	)

	var explanation: String = ""

	if not within_mass_limit:
		explanation = (
            "B-MO: We're %.1f kg over "
			+ "the launch mass limit!"
		) % absf(mass_margin_kg)
	elif not enough_thrust:
		explanation = (
            "B-MO: Our initial thrust-to-weight "
			+ "ratio is too low!"
		)
	elif not within_budget:
		explanation = (
            "B-MO: This spacecraft exceeds "
			+ "our mission budget!"
		)
	else:
		explanation = (
            "B-MO: Initial launch checks passed! "
			+ "Mass, thrust and budget are acceptable."
		)

	return {
		"success": passed,
		"valid": true,
		"boss": "Dr. Delta-V",
		"attack": "Gravity Well Launch Check",
		"mass_kg": mass_kg,
		"mass_limit_kg": mass_limit_kg,
		"mass_margin_kg": mass_margin_kg,
		"thrust_kn": thrust_kn,
		"surface_gravity_m_s2": gravity,
		"gravity_source": "NASA Earth Fact Sheet",
		"thrust_to_weight": thrust_to_weight,
		"within_mass_limit": within_mass_limit,
		"enough_thrust": enough_thrust,
		"within_budget": within_budget,
		"explanation": explanation
	}


# ==========================================
# DR. DOWNLINK - COMMUNICATION CHECK
# ==========================================

func check_communications(
	stats: Dictionary,
	observation_minutes: float = OBSERVATION_DURATION_MIN,
	contact_minutes: float = GROUND_CONTACT_MIN,
	required_data_mb: float = REQUIRED_SCIENCE_DATA_MB
) -> Dictionary:

	if (
		observation_minutes < 0.0
		or contact_minutes < 0.0
		or required_data_mb < 0.0
	):
		return _invalid_result(
            "Invalid communication duration or target."
		)

	var data_rate: float = float(
		stats.get("science_data_mb_per_min", 0.0)
	)

	var downlink_rate: float = float(
		stats.get("downlink_mb_per_min", 0.0)
	)

	var storage_mb: float = float(
		stats.get("data_storage_mb", 0.0)
	)

	if (
		data_rate < 0.0
		or downlink_rate < 0.0
		or storage_mb < 0.0
	):
		return _invalid_result(
            "Invalid communication or storage values."
		)

	var data_generated_mb: float = (
		data_rate * observation_minutes
	)

	var data_stored_mb: float = minf(
		data_generated_mb,
		storage_mb
	)

	var data_lost_mb: float = maxf(
		data_generated_mb - storage_mb,
		0.0
	)

	var downlink_capacity_mb: float = (
		downlink_rate * contact_minutes
	)

	var data_returned_mb: float = minf(
		data_stored_mb,
		downlink_capacity_mb
	)

	var passed: bool = (
		data_returned_mb >= required_data_mb
	)

	var explanation: String = ""

	if passed:
		explanation = (
            "B-MO: Transmission successful! "
			+ "%.1f MB of data reached our receiver."
		) % data_returned_mb
	else:
		var missing_mb: float = (
			required_data_mb - data_returned_mb
		)

		explanation = (
            "B-MO: Incomplete transmission! "
			+ "We still need %.1f MB of data."
		) % missing_mb

	return {
		"success": passed,
		"valid": true,
		"boss": "Dr. Downlink",
		"attack": "Ground Pass Bottleneck",
		"data_generated_mb": data_generated_mb,
		"data_stored_mb": data_stored_mb,
		"data_lost_mb": data_lost_mb,
		"downlink_capacity_mb": downlink_capacity_mb,
		"data_returned_mb": data_returned_mb,
		"required_data_mb": required_data_mb,
		"storage_mb": storage_mb,
		"explanation": explanation
	}


# ==========================================
# COMPLETE ENGINEERING EVALUATION
# ==========================================

func evaluate_mission(stats: Dictionary) -> Dictionary:
	var eclipse: Dictionary = check_eclipse(stats)
	var launch: Dictionary = check_launch(stats)
	var communications: Dictionary = (
		check_communications(stats)
	)

	var passed: bool = (
		bool(eclipse.get("success", false))
		and bool(launch.get("success", false))
		and bool(communications.get("success", false))
	)

	return {
		"success": passed,
		"eclipse": eclipse,
		"launch": launch,
		"communications": communications,
		"explanation": (
            "All engineering checks passed!"
			if passed
			else "One or more engineering checks failed."
		)
	}


func _invalid_result(reason: String) -> Dictionary:
	return {
		"success": false,
		"valid": false,
		"explanation": reason
	}
