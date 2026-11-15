
extends Node

# ==========================================
# SPACE VAULT
# SPACECRAFT GAME STATE
# GODOT 4.7
#
# STEP 25 - REVISED REWARD PROGRESSION
#
# 6 starter components
# 3 components from each Scientist
# 18 components in total
#
# Preserves:
# - SpacecraftManager
# - MissionSimulation
# - Equipment management
# - Ship statistics
# - Component unlocking
# - Saved progress
# - Scientist progression
# - Existing ShipBuilder integration
# ==========================================

signal equipment_changed
signal inventory_changed
signal progress_changed

const SAVE_PATH: String = (
	"user://space_vault_progress.json"
)

const SCIENTIST_ORDER: Array[String] = [
	"niq",
	"gabby",
	"ahmed",
	"celine"
]

const COMPONENT_CATEGORIES: Array[String] = [
	"engine",
	"battery",
	"solar",
	"scanner",
	"communication",
	"fuel"
]

# ==========================================
# REWARD PROGRESSION
# ==========================================

# Each category is expected to contain
# three components.
#
# Index 0 = Starter
# Index 1 = Intermediate
# Index 2 = Advanced
#
# Rewards are resolved from ComponentDatabase.
# No unverified component IDs are hardcoded.

const REWARD_CATEGORIES: Dictionary = {
	"niq": [
		"engine",
		"fuel",
		"solar"
	],

	"gabby": [
		"scanner",
		"communication",
		"battery"
	],

	"ahmed": [
		"engine",
		"battery",
		"fuel"
	],

	"celine": [
		"solar",
		"scanner",
		"communication"
	]
}

# The first two Scientists award
# intermediate parts.
#
# The final two award advanced parts
# from categories not yet upgraded.

const REWARD_TIERS: Dictionary = {
	"niq": 1,
	"gabby": 1,
	"ahmed": 2,
	"celine": 2
}

const CATEGORY_NAMES: Dictionary = {
	"engine": "Engine",
	"battery": "Battery",
	"solar": "Solar Panel",
	"scanner": "Science Scanner",
	"communication": "Communication",
	"fuel": "Fuel Tank"
}

# ==========================================
# DEVELOPMENT SETTINGS
# ==========================================

# false = Normal game progression
# true = Unlock everything for testing

var development_unlock_all: bool = false

# ==========================================
# MAIN GAME STATE
# ==========================================

var spacecraft: SpacecraftManager
var simulator: MissionSimulation

var unlocked_components: Array[String] = []
var completed_scientists: Array[String] = []

var starter_components: Array[String] = []

var scientist_rewards: Dictionary = {}

var progression_valid: bool = true


# ==========================================
# INITIALISATION
# ==========================================

func _ready() -> void:

	spacecraft = SpacecraftManager.new()
	simulator = MissionSimulation.new()

	_build_component_progression()

	_seed_starter_components()

	_load_progress()

	print("")
	print("================================")
	print("SPACE VAULT GAME STATE READY")
	print("================================")

	print(
		"Unlocked parts: ",
		unlocked_components.size()
	)

	print(
		"Completed Scientists: ",
		completed_scientists.size()
	)

	print(
		"Progression valid: ",
		progression_valid
	)

	print("================================")
	print("")


# ==========================================
# COMPONENT DATABASE HELPERS
# ==========================================

func _is_valid_component(
	component_id: String
) -> bool:

	if component_id.is_empty():
		return false

	var component: Dictionary = (
		spacecraft.database.get_component(
			component_id
		)
	)

	return not component.is_empty()


func _get_category_components(
	category: String
) -> Array:

	return (
		spacecraft.database
		.get_components_by_category(category)
	)


func _get_component_at(
	category: String,
	index: int
) -> String:

	var components: Array = (
		_get_category_components(category)
	)

	if index < 0:
		return ""

	if index >= components.size():
		return ""

	var value: Variant = components[index]

	if not value is Dictionary:
		return ""

	var component: Dictionary = value

	var component_id: String = str(
		component.get("id", "")
	)

	if not _is_valid_component(component_id):
		return ""

	return component_id


func _get_component_name(
	component_id: String
) -> String:

	if not _is_valid_component(component_id):
		return component_id

	var component: Dictionary = (
		spacecraft.database.get_component(
			component_id
		)
	)

	return str(
		component.get("name", component_id)
	)


# ==========================================
# BUILD PROGRESSION
# ==========================================

func _build_component_progression() -> void:

	starter_components.clear()
	scientist_rewards.clear()

	progression_valid = true

	# Check the database before assigning
	# rewards to any Scientist.

	for category in COMPONENT_CATEGORIES:

		var parts: Array = (
			_get_category_components(category)
		)

		if parts.size() != 3:

			progression_valid = false

			push_warning(
				"SPACE VAULT: Expected 3 parts in "
				+ category
				+ ", found "
				+ str(parts.size())
			)

		var starter_id: String = (
			_get_component_at(category, 0)
		)

		if starter_id.is_empty():

			progression_valid = false

			push_warning(
				"Missing starter component: "
				+ category
			)

		else:
			starter_components.append(
				starter_id
			)

	# Build the three-part reward
	# for each Scientist.

	for scientist_id in SCIENTIST_ORDER:

		var reward_parts: Array[String] = []

		var categories: Array = (
			REWARD_CATEGORIES.get(
				scientist_id,
				[]
			)
		)

		var tier: int = int(
			REWARD_TIERS.get(
				scientist_id,
				1
			)
		)

		for category_value in categories:

			var category: String = str(
				category_value
			)

			var part_id: String = (
				_get_component_at(
					category,
					tier
				)
			)

			if part_id.is_empty():

				progression_valid = false

				push_warning(
					"Missing reward for "
					+ scientist_id
					+ ": "
					+ category
				)

			else:
				reward_parts.append(
					part_id
				)

		scientist_rewards[scientist_id] = (
			reward_parts
		)

	# Check that every one of the 18
	# components has a unique slot.

	var all_ids: Array[String] = []

	for component_id in starter_components:

		if not all_ids.has(component_id):
			all_ids.append(component_id)

	for scientist_id in SCIENTIST_ORDER:

		var rewards: Array = (
			scientist_rewards.get(
				scientist_id,
				[]
			)
		)

		for value in rewards:

			var component_id: String = str(
				value
			)

			if all_ids.has(component_id):

				progression_valid = false

				push_warning(
					"Duplicate progression reward: "
					+ component_id
				)

			else:
				all_ids.append(component_id)

	if all_ids.size() != 18:

		progression_valid = false

		push_warning(
			"Expected 18 unique parts; found "
			+ str(all_ids.size())
		)

	_print_reward_plan()


func _print_reward_plan() -> void:

	print("")
	print("SPACE VAULT COMPONENT REWARDS")
	print("----------------------------")

	print("STARTER COMPONENTS")

	for component_id in starter_components:

		print(
			"  ",
			_get_component_name(
				component_id
			)
		)

	for scientist_id in SCIENTIST_ORDER:

		print("")
		print(
			scientist_id.to_upper(),
			" REWARDS"
		)

		var parts: Array = (
			scientist_rewards.get(
				scientist_id,
				[]
			)
		)

		for value in parts:

			var component_id: String = str(
				value
			)

			print(
				"  ",
				_get_component_name(
					component_id
				)
			)

	print("----------------------------")


# ==========================================
# STARTER COMPONENTS
# ==========================================

func _seed_starter_components() -> void:

	for component_id in starter_components:

		if not unlocked_components.has(
			component_id
		):

			unlocked_components.append(
				component_id
			)


# ==========================================
# COMPONENT UNLOCKING
# ==========================================

func unlock_component(
	component_id: String
) -> bool:

	if not _is_valid_component(
		component_id
	):

		push_warning(
			"Cannot unlock unknown component: "
			+ component_id
		)

		return false

	if unlocked_components.has(
		component_id
	):
		return true

	unlocked_components.append(
		component_id
	)

	inventory_changed.emit()

	_save_progress()

	print(
		"Component unlocked: ",
		_get_component_name(component_id)
	)

	return true


func is_component_unlocked(
	component_id: String
) -> bool:

	if development_unlock_all:
		return true

	return unlocked_components.has(
		component_id
	)


func get_unlocked_components() -> Array[String]:

	return unlocked_components.duplicate()


# ==========================================
# SCIENTIST PROGRESSION
# ==========================================

func get_completed_scientists() -> Array[String]:

	return completed_scientists.duplicate()


func has_defeated_scientist(
	scientist_id: String
) -> bool:

	return completed_scientists.has(
		scientist_id
	)


func get_next_scientist_id() -> String:

	for scientist_id in SCIENTIST_ORDER:

		if not completed_scientists.has(
			scientist_id
		):

			return scientist_id

	return ""


func can_challenge_scientist(
	scientist_id: String
) -> bool:

	if not SCIENTIST_ORDER.has(
		scientist_id
	):
		return false

	# Previously defeated Scientists
	# can be replayed.
	#
	# They do not award duplicates.

	if has_defeated_scientist(
		scientist_id
	):
		return true

	return (
		scientist_id
		== get_next_scientist_id()
	)


func is_final_escape_unlocked() -> bool:

	return (
		get_next_scientist_id().is_empty()
	)


# ==========================================
# REWARD HELPERS
# ==========================================

func get_scientist_rewards(
	scientist_id: String
) -> Array[String]:

	var result: Array[String] = []

	var values: Array = (
		scientist_rewards.get(
			scientist_id,
			[]
		)
	)

	for value in values:

		result.append(
			str(value)
		)

	return result


func _get_reward_summary(
	scientist_id: String
) -> String:

	var categories: Array = (
		REWARD_CATEGORIES.get(
			scientist_id,
			[]
		)
	)

	var names: Array[String] = []

	for value in categories:

		var category: String = str(
			value
		)

		names.append(
			str(
				CATEGORY_NAMES.get(
					category,
					category
				)
			)
		)

	return ", ".join(names)


# ==========================================
# SCIENTIST VICTORY
# ==========================================

func complete_scientist_battle(
	scientist_id: String
) -> Dictionary:

	if not SCIENTIST_ORDER.has(
		scientist_id
	):

		return {
			"success": false,
			"reason": "Unknown Scientist"
		}

	# Already completed:
	# no duplicate rewards.

	if completed_scientists.has(
		scientist_id
	):

		return {
			"success": true,
			"already_completed": true,
			"reward_id": "",
			"reward_ids": [],
			"reward_name": "Already collected",
			"next_boss": get_next_scientist_id(),
			"all_completed": is_final_escape_unlocked()
		}

	# Prevent skipping Scientists.

	if scientist_id != get_next_scientist_id():

		return {
			"success": false,
			"reason": "Defeat Scientists in order"
		}

	# Prevent broken database records
	# from producing incomplete rewards.

	if not progression_valid:

		return {
			"success": false,
			"reason": "Component progression is invalid"
		}

	var rewards: Array[String] = (
		get_scientist_rewards(
			scientist_id
		)
	)

	if rewards.size() != 3:

		return {
			"success": false,
			"reason": "Three rewards are required"
		}

	# Validate all three parts before
	# recording this victory.

	for component_id in rewards:

		if not _is_valid_component(
			component_id
		):

			return {
				"success": false,
				"reason": (
					"Missing reward: "
					+ component_id
				)
			}

	# Unlock all three rewards.

	for component_id in rewards:

		if not unlocked_components.has(
			component_id
		):

			unlocked_components.append(
				component_id
			)

	# Record the victory.

	completed_scientists.append(
		scientist_id
	)

	# Save all rewards together.

	_save_progress()

	inventory_changed.emit()
	progress_changed.emit()

	print("")
	print(
		"SCIENTIST DEFEATED: ",
		scientist_id
	)

	for component_id in rewards:

		print(
			"REWARD UNLOCKED: ",
			_get_component_name(
				component_id
			)
		)

	var reward_summary: String = (
		_get_reward_summary(scientist_id)
	)

	return {
		"success": true,
		"already_completed": false,
		"reward_id": rewards[0],
		"reward_ids": rewards.duplicate(),
		"reward_name": reward_summary,
		"next_boss": get_next_scientist_id(),
		"all_completed": is_final_escape_unlocked()
	}


# ==========================================
# EQUIPMENT MANAGEMENT
# ==========================================

func equip_component(
	component_id: String
) -> bool:

	if not is_component_unlocked(
		component_id
	):

		print(
			"Component not unlocked: ",
			component_id
		)

		return false

	var success: bool = (
		spacecraft.equip_component(
			component_id
		)
	)

	if success:

		equipment_changed.emit()

		_save_progress()

	return success


func unequip_component(
	category: String
) -> bool:

	var success: bool = (
		spacecraft.unequip_component(
			category
		)
	)

	if success:

		equipment_changed.emit()

		_save_progress()

	return success


func clear_equipment() -> void:

	spacecraft.clear_equipment()

	equipment_changed.emit()

	_save_progress()


# ==========================================
# EQUIPMENT INFORMATION
# ==========================================

func get_equipped_component(
	category: String
) -> String:

	return spacecraft.get_equipped_component(
		category
	)


func get_equipped_components() -> Dictionary:

	return spacecraft.get_equipped_components()


func get_ship_stats() -> Dictionary:

	return spacecraft.get_ship_stats()


func get_available_components(
	category: String
) -> Array:

	var components: Array = (
		spacecraft.database
		.get_components_by_category(
			category
		)
	)

	var available: Array = []

	for component_value in components:

		if not component_value is Dictionary:
			continue

		var component: Dictionary = (
			component_value
		)

		var component_id: String = str(
			component.get(
				"id",
				""
			)
		)

		if is_component_unlocked(
			component_id
		):

			available.append(
				component
			)

	return available


# ==========================================
# SPACECRAFT STATUS
# ==========================================

func is_ship_complete() -> bool:

	return spacecraft.is_ship_complete()


func get_missing_categories() -> Array[String]:

	return spacecraft.get_missing_categories()


# ==========================================
# ENGINEERING SIMULATIONS
# ==========================================

func check_eclipse(
	duration_minutes: float = 35.0
) -> Dictionary:

	return simulator.check_eclipse(
		get_ship_stats(),
		duration_minutes
	)


func check_launch(
	mass_limit_kg: float = 500.0
) -> Dictionary:

	return simulator.check_launch(
		get_ship_stats(),
		mass_limit_kg
	)


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


func evaluate_mission() -> Dictionary:

	return simulator.evaluate_mission(
		get_ship_stats()
	)


# ==========================================
# SAVE PROGRESS
# ==========================================

func _save_progress() -> void:

	var data: Dictionary = {
		"version": 2,

		"unlocked_components": (
			unlocked_components.duplicate()
		),

		"completed_scientists": (
			completed_scientists.duplicate()
		),

		"equipped_components": (
			spacecraft.get_equipped_components()
		)
	}

	var file: FileAccess = (
		FileAccess.open(
			SAVE_PATH,
			FileAccess.WRITE
		)
	)

	if file == null:

		push_warning(
			"Cannot save SPACE VAULT progress: "
			+ str(
				FileAccess.get_open_error()
			)
		)

		return

	file.store_string(
		JSON.stringify(
			data,
			"\t"
		)
	)

	file.close()


# ==========================================
# LOAD PROGRESS
# ==========================================

func _load_progress() -> void:

	if not FileAccess.file_exists(
		SAVE_PATH
	):
		return

	var file: FileAccess = (
		FileAccess.open(
			SAVE_PATH,
			FileAccess.READ
		)
	)

	if file == null:

		push_warning(
			"Cannot load SPACE VAULT progress"
		)

		return

	var parsed: Variant = (
		JSON.parse_string(
			file.get_as_text()
		)
	)

	file.close()

	if not parsed is Dictionary:

		push_warning(
			"Invalid SPACE VAULT save file"
		)

		return

	var saved: Dictionary = parsed

	# Restore previously unlocked parts.

	var saved_unlocks: Variant = (
		saved.get(
			"unlocked_components",
			[]
		)
	)

	if saved_unlocks is Array:

		for value in saved_unlocks:

			var component_id: String = str(
				value
			)

			if (
				_is_valid_component(component_id)
				and not unlocked_components.has(
					component_id
				)
			):

				unlocked_components.append(
					component_id
				)

	# Restore completed Scientists.
	#
	# Existing Step 25 saves remain
	# compatible.
	#
	# Previously defeated Scientists
	# receive their missing new rewards.

	var saved_bosses: Variant = (
		saved.get(
			"completed_scientists",
			[]
		)
	)

	if saved_bosses is Array:

		for scientist_id in SCIENTIST_ORDER:

			if saved_bosses.has(
				scientist_id
			):

				completed_scientists.append(
					scientist_id
				)

				var rewards: Array[String] = (
					get_scientist_rewards(
						scientist_id
					)
				)

				for component_id in rewards:

					if (
						_is_valid_component(component_id)
						and not unlocked_components.has(
							component_id
						)
					):

						unlocked_components.append(
							component_id
						)

			else:
				break

	# Restore equipped rocket parts.

	var saved_equipment: Variant = (
		saved.get(
			"equipped_components",
			{}
		)
	)

	if saved_equipment is Dictionary:

		for category in COMPONENT_CATEGORIES:

			var component_id: String = str(
				saved_equipment.get(
					category,
					""
				)
			)

			if (
				not component_id.is_empty()
				and is_component_unlocked(
					component_id
				)
			):

				spacecraft.equip_component(
					component_id
				)

	# Upgrade an older save to the
	# new 3-reward progression layout.

	_save_progress()


# ==========================================
# RESET PROGRESS
# ==========================================

# Call this only when intentionally
# starting over or testing a fresh game.

func reset_progress() -> void:

	unlocked_components.clear()

	completed_scientists.clear()

	spacecraft.clear_equipment()

	_seed_starter_components()

	_save_progress()

	inventory_changed.emit()
	equipment_changed.emit()
	progress_changed.emit()


# ==========================================
# DEBUG: SHOW UNLOCKED PARTS
# ==========================================

func print_inventory() -> void:

	print("")
	print("SPACE VAULT INVENTORY")
	print("--------------------")

	for component_id in unlocked_components:

		print(
			_get_component_name(
				component_id
			)
		)

	print("--------------------")


# ==========================================
# DEBUG: SHOW PROGRESSION
# ==========================================

func print_progression() -> void:

	print("")
	print("SPACE VAULT PROGRESSION")
	print("-----------------------")

	for scientist_id in SCIENTIST_ORDER:

		var status: String = "LOCKED"

		if completed_scientists.has(
			scientist_id
		):

			status = "DEFEATED"

		elif scientist_id == get_next_scientist_id():

			status = "AVAILABLE"

		print(
			scientist_id.to_upper(),
			": ",
			status
		)

	print("-----------------------")
