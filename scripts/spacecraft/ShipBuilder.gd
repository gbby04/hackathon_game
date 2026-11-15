
extends Control

# SPACE VAULT - ROCKET ASSEMBLY
# Godot 4.7
#
# PREVIEW -> CONFIRM -> EQUIP
#
# Selecting a part previews its effects.
# Confirm installs or removes it.
# Cancel restores the existing ship.
# After confirmation, red/green changes disappear.
#
# No additional scenes or scripts required.

signal close_requested

const BG: Color = Color("#091524")
const HEADER: Color = Color("#10243a")
const CARD: Color = Color("#162940")
const CARD_HOVER: Color = Color("#243e59")
const BORDER: Color = Color("#29445c")
const TEXT_MAIN: Color = Color("#eaf6ff")
const TEXT_MUTED: Color = Color("#a5b9cc")
const ACCENT: Color = Color("#50d4e8")
const SELECTED: Color = Color("#176f91")
const GOOD: Color = Color("#7deda4")
const BAD: Color = Color("#ff8a8a")
const NEUTRAL: Color = Color("#99aabe")
const WARNING: Color = Color("#ffca70")

const CATEGORIES: Array[Dictionary] = [
	{"name": "Engine", "key": "engine"},
	{"name": "Battery", "key": "battery"},
	{"name": "Solar Panel", "key": "solar"},
	{"name": "Science Scanner", "key": "scanner"},
	{"name": "Communication", "key": "communication"},
	{"name": "Fuel Tank", "key": "fuel"}
]

const STAT_ROWS: Array[Dictionary] = [
	{
		"name": "MASS",
		"key": "mass_kg",
		"unit": "kg",
		"lower": true
	},
	{
		"name": "POWER",
		"key": "power_w",
		"unit": "W",
		"lower": true
	},
	{
		"name": "BATTERY",
		"key": "battery_wh",
		"unit": "Wh",
		"lower": false
	},
	{
		"name": "SOLAR",
		"key": "solar_generation_w",
		"unit": "W",
		"lower": false
	},
	{
		"name": "COST",
		"key": "cost_credits",
		"unit": "cr",
		"lower": true
	},
	{
		"name": "BUDGET",
		"key": "budget_remaining",
		"unit": "cr",
		"lower": false
	},
	{
		"name": "SCIENCE",
		"key": "science_score",
		"unit": "",
		"lower": false
	},
	{
		"name": "THRUST",
		"key": "thrust_kn",
		"unit": "kN",
		"lower": false
	},
	{
		"name": "DOWNLINK",
		"key": "downlink_mb_per_min",
		"unit": "MB/m",
		"lower": false
	}
]

const COMPONENT_STAT_KEYS: Array[String] = [
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


# ==========================================
# ROCKET PREVIEW CONTROL
# ==========================================

class RocketPreview:
	extends Control

	var equipment: Dictionary = {}

	func update_rocket(
		new_equipment: Dictionary
	) -> void:
		equipment = new_equipment.duplicate(true)
		queue_redraw()


	func _has_part(category: String) -> bool:
		return not str(
			equipment.get(category, "")
		).is_empty()


	func _draw() -> void:
		var outline: Color = Color("#50687f")
		var hull: Color = Color("#8cc7d7")
		var light: Color = Color("#d9f3f5")
		var dark: Color = Color("#2a506c")

		var count: int = 0

		for category in equipment.keys():
			if _has_part(str(category)):
				count += 1

		# Assembly guide
		draw_line(
			Vector2(52, 6),
			Vector2(52, 168),
			Color("#29445c"),
			1.0
		)

		# Rocket outline
		draw_line(
			Vector2(35, 45),
			Vector2(52, 12),
			outline,
			2.0
		)

		draw_line(
			Vector2(52, 12),
			Vector2(69, 45),
			outline,
			2.0
		)

		draw_rect(
			Rect2(35, 45, 34, 88),
			outline,
			false,
			2.0
		)

		draw_line(
			Vector2(35, 100),
			Vector2(17, 122),
			outline,
			2.0
		)

		draw_line(
			Vector2(69, 100),
			Vector2(87, 122),
			outline,
			2.0
		)

		# Body appears once a part is installed.
		if count > 0:
			draw_rect(
				Rect2(37, 47, 30, 84),
				hull
			)

			draw_rect(
				Rect2(42, 49, 7, 80),
				light
			)

			draw_rect(
				Rect2(61, 47, 6, 84),
				dark
			)

		# Science scanner: nose section
		if _has_part("scanner"):
			var nose: PackedVector2Array = (
				PackedVector2Array([
					Vector2(52, 12),
					Vector2(35, 45),
					Vector2(69, 45)
				])
			)

			draw_colored_polygon(nose, light)

			draw_line(
				Vector2(52, 12),
				Vector2(35, 45),
				dark,
				2.0
			)

			draw_line(
				Vector2(52, 12),
				Vector2(69, 45),
				dark,
				2.0
			)

		# Fuel tank
		if _has_part("fuel"):
			draw_rect(
				Rect2(42, 77, 20, 40),
				Color("#5b86a8")
			)

			draw_rect(
				Rect2(43, 85, 18, 3),
				Color("#c5e2ea")
			)

			draw_rect(
				Rect2(43, 105, 18, 3),
				Color("#c5e2ea")
			)

		# Battery
		if _has_part("battery"):
			draw_rect(
				Rect2(43, 57, 18, 12),
				Color("#e1c25c")
			)

			draw_rect(
				Rect2(50, 59, 4, 8),
				Color("#f8ecae")
			)

		# Solar panels
		if _has_part("solar"):
			draw_rect(
				Rect2(9, 77, 25, 36),
				Color("#357caa")
			)

			draw_rect(
				Rect2(70, 77, 25, 36),
				Color("#357caa")
			)

			for index in range(3):
				var line_x: float = (
					13.0 + float(index) * 8.0
				)

				draw_line(
					Vector2(line_x, 79),
					Vector2(line_x, 111),
					Color("#9bd0e6"),
					1.0
				)

				draw_line(
					Vector2(line_x + 61, 79),
					Vector2(line_x + 61, 111),
					Color("#9bd0e6"),
					1.0
				)

		# Communication antenna
		if _has_part("communication"):
			draw_line(
				Vector2(68, 57),
				Vector2(87, 45),
				Color("#a9e8ee"),
				2.0
			)

			draw_circle(
				Vector2(87, 45),
				4.0,
				Color("#72e9d3")
			)

		# Engine
		if _has_part("engine"):
			draw_rect(
				Rect2(41, 132, 22, 12),
				Color("#70849c")
			)

			draw_rect(
				Rect2(45, 144, 14, 7),
				Color("#49596c")
			)

			draw_colored_polygon(
				PackedVector2Array([
					Vector2(45, 151),
					Vector2(52, 168),
					Vector2(59, 151)
				]),
				Color("#ffb85d")
			)

			draw_colored_polygon(
				PackedVector2Array([
					Vector2(49, 151),
					Vector2(52, 162),
					Vector2(55, 151)
				]),
				Color("#fff0aa")
			)


# ==========================================
# STATE
# ==========================================

var current_category: String = "engine"

# Pending selection has NOT been equipped yet.
var pending_component_id: String = ""
var pending_category: String = ""
var pending_remove: bool = false

var database: ComponentDatabase

var category_container: VBoxContainer
var parts_container: VBoxContainer

var equipped_label: Label
var message_label: Label
var assembly_label: Label

var confirm_button: Button
var cancel_button: Button

var preview: RocketPreview
var stat_labels: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(640, 360)

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	database = SpacecraftGameState.spacecraft.database

	_build_interface()
	_refresh_all()


# ==========================================
# STYLE HELPERS
# ==========================================

func _style(
	background: Color,
	border: Color = BORDER
) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()

	result.bg_color = background
	result.border_color = border
	result.set_border_width_all(1)
	result.set_corner_radius_all(4)

	return result


func _panel(
	at: Vector2,
	dimensions: Vector2,
	colour: Color
) -> Panel:
	var result: Panel = Panel.new()

	result.position = at
	result.size = dimensions

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	result.add_theme_stylebox_override(
		"panel",
		_style(colour)
	)

	add_child(result)
	return result


func _label(
	value: String,
	at: Vector2,
	dimensions: Vector2,
	font_size: int = 10,
	colour: Color = TEXT_MAIN
) -> Label:
	var result: Label = Label.new()

	result.text = value
	result.position = at
	result.size = dimensions

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	result.add_theme_font_size_override(
		"font_size",
		font_size
	)

	result.add_theme_color_override(
		"font_color",
		colour
	)

	add_child(result)
	return result


func _style_button(
	button: Button,
	selected: bool = false
) -> void:
	var normal: Color = CARD_HOVER

	if selected:
		normal = SELECTED

	button.add_theme_stylebox_override(
		"normal",
		_style(normal)
	)

	button.add_theme_stylebox_override(
		"hover",
		_style(Color("#247e9e"), ACCENT)
	)

	button.add_theme_stylebox_override(
		"pressed",
		_style(Color("#125773"), ACCENT)
	)

	button.add_theme_stylebox_override(
		"disabled",
		_style(Color("#28384a"))
	)

	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	for key in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
        "font_disabled_color"
	]:
		button.add_theme_color_override(
			key,
			TEXT_MAIN
		)

	button.add_theme_font_size_override(
		"font_size",
		10
	)


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


# ==========================================
# BUILD INTERFACE
# ==========================================

func _build_interface() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = BG
	add_child(bg)

	bg.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	bg.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	# Header
	_panel(
		Vector2(8, 7),
		Vector2(624, 51),
		HEADER
	)

	_label(
		"MATCHA // ROCKET ASSEMBLY",
		Vector2(19, 14),
		Vector2(325, 22),
		16,
		ACCENT
	)

	_label(
		"BUILD JOE PENG'S ESCAPE SPACECRAFT",
		Vector2(20, 38),
		Vector2(315, 12),
		9,
		TEXT_MUTED
	)

	var back: Button = Button.new()
	back.text = "BACK"
	back.position = Vector2(522, 17)
	back.size = Vector2(98, 31)

	_style_button(back, true)

	back.pressed.connect(_on_back_pressed)

	add_child(back)

	# Categories
	_panel(
		Vector2(8, 67),
		Vector2(123, 244),
		CARD
	)

	_label(
		"COMPONENTS",
		Vector2(16, 79),
		Vector2(111, 18),
		11,
		ACCENT
	)

	category_container = VBoxContainer.new()
	category_container.position = Vector2(15, 108)
	category_container.size = Vector2(109, 190)

	category_container.add_theme_constant_override(
		"separation",
		5
	)

	add_child(category_container)

	# Available parts
	_panel(
		Vector2(139, 67),
		Vector2(204, 244),
		CARD
	)

	_label(
		"AVAILABLE PARTS",
		Vector2(148, 79),
		Vector2(184, 18),
		11,
		ACCENT
	)

	equipped_label = _label(
		"",
		Vector2(148, 101),
		Vector2(183, 18),
		9,
		GOOD
	)

	equipped_label.clip_text = true

	# Shorter scrolling area leaves space
	# for CONFIRM and CANCEL underneath.
	var scroll: ScrollContainer = (
		ScrollContainer.new()
	)

	scroll.position = Vector2(147, 122)
	scroll.size = Vector2(188, 143)

	scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	add_child(scroll)

	parts_container = VBoxContainer.new()

	parts_container.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	parts_container.add_theme_constant_override(
		"separation",
		4
	)

	scroll.add_child(parts_container)

	confirm_button = Button.new()
	confirm_button.text = "CONFIRM"
	confirm_button.position = Vector2(147, 274)
	confirm_button.size = Vector2(91, 27)

	_style_button(confirm_button, true)

	confirm_button.pressed.connect(
		_confirm_selection
	)

	add_child(confirm_button)

	cancel_button = Button.new()
	cancel_button.text = "CANCEL"
	cancel_button.position = Vector2(244, 274)
	cancel_button.size = Vector2(91, 27)

	_style_button(cancel_button)

	cancel_button.pressed.connect(
		_cancel_selection
	)

	add_child(cancel_button)

	# Rocket preview
	_panel(
		Vector2(350, 67),
		Vector2(110, 244),
		CARD
	)

	_label(
		"ROCKET",
		Vector2(361, 79),
		Vector2(88, 17),
		11,
		ACCENT
	)

	assembly_label = _label(
		"0 / 6 PARTS",
		Vector2(358, 100),
		Vector2(94, 19),
		10,
		WARNING
	)

	assembly_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	preview = RocketPreview.new()
	preview.position = Vector2(353, 121)
	preview.size = Vector2(104, 175)

	preview.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(preview)

	# Ship statistics
	_panel(
		Vector2(467, 67),
		Vector2(165, 244),
		CARD
	)

	_label(
		"SHIP STATS",
		Vector2(476, 79),
		Vector2(148, 19),
		11,
		ACCENT
	)

	var row_y: float = 108.0

	for entry in STAT_ROWS:
		var key: String = str(entry["key"])

		_label(
			str(entry["name"]),
			Vector2(475, row_y),
			Vector2(61, 15),
			8,
			TEXT_MUTED
		)

		var value_label: Label = _label(
			"0",
			Vector2(531, row_y),
			Vector2(62, 15),
			8,
			TEXT_MAIN
		)

		value_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_RIGHT
		)

		var delta_label: Label = _label(
			"—",
			Vector2(595, row_y),
			Vector2(29, 15),
			8,
			NEUTRAL
		)

		delta_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_RIGHT
		)

		stat_labels[key] = {
			"value": value_label,
			"delta": delta_label,
			"unit": str(entry["unit"]),
			"lower": bool(entry["lower"])
		}

		row_y += 19.0

	_label(
		"ASSEMBLY STATUS",
		Vector2(476, 283),
		Vector2(145, 16),
		9,
		ACCENT
	)

	# Matcha dialogue
	_panel(
		Vector2(8, 318),
		Vector2(624, 34),
		HEADER
	)

	message_label = _label(
		"",
		Vector2(18, 329),
		Vector2(607, 16),
		10,
		TEXT_MAIN
	)


# ==========================================
# CATEGORY SELECTION
# ==========================================

func _refresh_all() -> void:
	_refresh_categories()
	_refresh_parts()
	_refresh_stats()
	_refresh_rocket()
	_refresh_confirmation_buttons()

	_message(
        "MATCHA: Good day, sir. Shall we assemble our escape plan?"
	)


func _refresh_categories() -> void:
	_clear(category_container)

	for category in CATEGORIES:
		var key: String = str(
			category["key"]
		)

		var button: Button = Button.new()
		button.text = str(category["name"])
		button.custom_minimum_size = (
			Vector2(0, 27)
		)

		_style_button(
			button,
			key == current_category
		)

		button.pressed.connect(
			_select_category.bind(key)
		)

		category_container.add_child(button)


func _select_category(category: String) -> void:
	# Switching categories cancels any
	# unconfirmed selection.
	_clear_pending()

	current_category = category

	_refresh_categories()
	_refresh_parts()
	_refresh_stats()
	_refresh_rocket()
	_refresh_confirmation_buttons()

	_message(
        "MATCHA: Reviewing %s systems, sir. Choose carefully."
		% category
	)


func _get_equipped_id(
	category: String
) -> String:
	return SpacecraftGameState.get_equipped_component(
		category
	)


# ==========================================
# PART CARDS
# ==========================================

func _refresh_parts() -> void:
	_clear(parts_container)

	var equipped_id: String = (
		_get_equipped_id(current_category)
	)

	var equipped_part: Dictionary = {}

	if not equipped_id.is_empty():
		equipped_part = database.get_component(
			equipped_id
		)

	equipped_label.text = (
        "EQUIPPED: %s"
		% str(equipped_part.get("name", "None"))
	)

	var components: Array = (
		database.get_components_by_category(
			current_category
		)
	)

	for value in components:
		if not value is Dictionary:
			continue

		var part: Dictionary = value

		var id: String = str(
			part.get("id", "")
		)

		if id.is_empty():
			continue

		var is_equipped: bool = (
			id == equipped_id
		)

		var is_pending: bool = (
			pending_category == current_category
			and pending_component_id == id
		)

		var unlocked: bool = (
			SpacecraftGameState.is_component_unlocked(id)
		)

		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(0, 43)
		button.text = ""

		button.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		_style_button(
			button,
			is_pending or is_equipped
		)

		var title: String = str(
			part.get("name", id)
		)

		var name_label: Label = Label.new()
		name_label.text = title
		name_label.position = Vector2(6, 3)
		name_label.size = Vector2(132, 14)
		name_label.clip_text = true
		name_label.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		name_label.add_theme_font_size_override(
			"font_size",
			9
		)

		name_label.add_theme_color_override(
			"font_color",
			TEXT_MAIN
		)

		button.add_child(name_label)

		var status: Label = Label.new()
		status.position = Vector2(137, 3)
		status.size = Vector2(43, 14)

		status.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_RIGHT
		)

		status.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		status.add_theme_font_size_override(
			"font_size",
			8
		)

		if is_pending:
			status.text = (
				"REMOVE" if pending_remove
				else "PREVIEW"
			)
			status.add_theme_color_override(
				"font_color",
				WARNING
			)

		elif is_equipped:
			status.text = "ON"
			status.add_theme_color_override(
				"font_color",
				GOOD
			)

		elif unlocked:
			status.text = "SELECT"
			status.add_theme_color_override(
				"font_color",
				ACCENT
			)

		else:
			status.text = "LOCK"
			status.add_theme_color_override(
				"font_color",
				NEUTRAL
			)

		button.add_child(status)

		var info: Label = Label.new()
		info.text = (
            "%.0f kg | %.0f W | %.0f cr"
		) % [
			float(part.get("mass_kg", 0.0)),
			float(part.get("power_w", 0.0)),
			float(part.get("cost_credits", 0.0))
		]

		info.position = Vector2(6, 19)
		info.size = Vector2(174, 13)

		info.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		info.add_theme_font_size_override(
			"font_size",
			8
		)

		info.add_theme_color_override(
			"font_color",
			TEXT_MUTED
		)

		button.add_child(info)

		var hint: Label = Label.new()
		hint.position = Vector2(6, 32)
		hint.size = Vector2(174, 10)
		hint.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		hint.add_theme_font_size_override(
			"font_size",
			8
		)

		if is_pending:
			hint.text = "Awaiting confirmation"
			hint.add_theme_color_override(
				"font_color",
				WARNING
			)

		elif is_equipped:
			hint.text = "Select to preview removal"
			hint.add_theme_color_override(
				"font_color",
				GOOD
			)

		else:
			hint.text = "Select to compare"
			hint.add_theme_color_override(
				"font_color",
				TEXT_MUTED
			)

		button.add_child(hint)

		if unlocked:
			button.pressed.connect(
				_select_part.bind(id)
			)
		else:
			button.disabled = true

		parts_container.add_child(button)


# ==========================================
# PENDING SELECTION
# ==========================================

func _select_part(
	component_id: String
) -> void:
	var equipped_id: String = (
		_get_equipped_id(current_category)
	)

	pending_category = current_category
	pending_component_id = component_id

	# Selecting the installed part
	# means the player wants to remove it.
	pending_remove = (
		component_id == equipped_id
	)

	_refresh_parts()
	_refresh_stats()
	_refresh_rocket()
	_refresh_confirmation_buttons()

	var part: Dictionary = (
		database.get_component(component_id)
	)

	if pending_remove:
		_message(
            "MATCHA: Remove %s, sir? Confirm when ready."
			% str(part.get("name", component_id))
		)
	else:
		_message(
            "MATCHA: Previewing %s, sir. Review the figures before confirming."
			% str(part.get("name", component_id))
		)


func _clear_pending() -> void:
	pending_component_id = ""
	pending_category = ""
	pending_remove = false


func _refresh_confirmation_buttons() -> void:
	var has_selection: bool = (
		not pending_component_id.is_empty()
	)

	confirm_button.disabled = not has_selection
	cancel_button.disabled = not has_selection

	if not has_selection:
		confirm_button.text = "CONFIRM"

	elif pending_remove:
		confirm_button.text = "REMOVE"

	else:
		confirm_button.text = "CONFIRM"


# ==========================================
# PREVIEW CALCULATIONS
# ==========================================

func _get_preview_stats() -> Dictionary:
	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	).duplicate(true)

	if pending_component_id.is_empty():
		return stats

	var equipped_id: String = (
		_get_equipped_id(pending_category)
	)

	var old_part: Dictionary = {}

	if not equipped_id.is_empty():
		old_part = database.get_component(
			equipped_id
		)

	var new_part: Dictionary = {}

	if not pending_remove:
		new_part = database.get_component(
			pending_component_id
		)

	# Adjust only the category being previewed.
	for key in COMPONENT_STAT_KEYS:
		var old_value: float = float(
			old_part.get(key, 0.0)
		)

		var new_value: float = float(
			new_part.get(key, 0.0)
		)

		stats[key] = (
			float(stats.get(key, 0.0))
			- old_value
			+ new_value
		)

	var max_budget: float = (
		SpacecraftManager.MAX_BUDGET
	)

	stats["budget_remaining"] = (
		max_budget
		- float(stats["cost_credits"])
	)

	stats["within_budget"] = (
		float(stats["cost_credits"]) <= max_budget
	)

	var equipment: Dictionary = (
		_get_preview_equipment()
	)

	var count: int = 0

	for category in equipment.keys():
		if not str(equipment[category]).is_empty():
			count += 1

	stats["equipped_count"] = count
	stats["complete"] = (count == 6)

	return stats


func _get_preview_equipment() -> Dictionary:
	var equipment: Dictionary = (
		SpacecraftGameState.get_equipped_components()
	)

	if not pending_component_id.is_empty():
		equipment[pending_category] = (
			"" if pending_remove
			else pending_component_id
		)

	return equipment


# ==========================================
# CONFIRM OR CANCEL
# ==========================================

func _confirm_selection() -> void:
	if pending_component_id.is_empty():
		return

	var part: Dictionary = database.get_component(
		pending_component_id
	)

	var part_name: String = str(
		part.get("name", pending_component_id)
	)

	var success: bool = false

	if pending_remove:
		success = (
			SpacecraftGameState.unequip_component(
				pending_category
			)
		)

	else:
		success = (
			SpacecraftGameState.equip_component(
				pending_component_id
			)
		)

	if not success:
		_message(
            "MATCHA: The change failed, sir. The current assembly is unchanged."
		)
		return

	var was_removal: bool = pending_remove

	# Clear the preview. All stat colours and
	# change indicators return to neutral.
	_clear_pending()

	_refresh_parts()
	_refresh_stats()
	_refresh_rocket()
	_refresh_confirmation_buttons()

	if was_removal:
		_message(
            "MATCHA: %s removed, sir. I have updated the assembly."
			% part_name
		)
	else:
		_message(
            "MATCHA: %s installed, sir. A small but respectable step toward escape."
			% part_name
		)


func _cancel_selection() -> void:
	if pending_component_id.is_empty():
		return

	_clear_pending()

	_refresh_parts()
	_refresh_stats()
	_refresh_rocket()
	_refresh_confirmation_buttons()

	_message(
        "MATCHA: Change cancelled, sir. A rare display of restraint."
	)


# ==========================================
# SHIP STATISTICS
# ==========================================

func _refresh_stats() -> void:
	var current_stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	var shown_stats: Dictionary = (
		_get_preview_stats()
	)

	var is_previewing: bool = (
		not pending_component_id.is_empty()
	)

	for key_value in stat_labels.keys():
		var key: String = str(key_value)
		var row: Dictionary = stat_labels[key]

		var value_label: Label = row["value"]
		var delta_label: Label = row["delta"]

		var shown: float = float(
			shown_stats.get(key, 0.0)
		)

		var current: float = float(
			current_stats.get(key, 0.0)
		)

		var unit: String = str(row["unit"])

		if key == "science_score":
			value_label.text = "%d" % int(shown)

		elif key == "downlink_mb_per_min":
			value_label.text = (
				"%.1f%s" % [shown, unit]
			)

		else:
			value_label.text = (
				"%.0f%s" % [shown, unit]
			)

		# After confirmation there are no
		# red or green indicators.
		if not is_previewing:
			delta_label.text = "—"

			delta_label.add_theme_color_override(
				"font_color",
				NEUTRAL
			)

			value_label.add_theme_color_override(
				"font_color",
				TEXT_MAIN
			)

			continue

		var change: float = shown - current

		delta_label.text = _format_delta(change)

		var colour: Color = _delta_colour(
			change,
			bool(row["lower"])
		)

		delta_label.add_theme_color_override(
			"font_color",
			colour
		)

		value_label.add_theme_color_override(
			"font_color",
			TEXT_MAIN if absf(change) < 0.001
			else colour
		)


func _format_delta(value: float) -> String:
	if absf(value) < 0.001:
		return "0"

	if value > 0.0:
		return "+%.0f" % value

	return "%.0f" % value


func _delta_colour(
	change: float,
	lower_is_better: bool
) -> Color:
	if absf(change) < 0.001:
		return NEUTRAL

	if lower_is_better:
		return GOOD if change < 0.0 else BAD

	return GOOD if change > 0.0 else BAD


# ==========================================
# ROCKET PREVIEW
# ==========================================

func _refresh_rocket() -> void:
	var equipment: Dictionary = (
		_get_preview_equipment()
	)

	preview.update_rocket(equipment)

	var stats: Dictionary = (
		_get_preview_stats()
	)

	var count: int = int(
		stats.get("equipped_count", 0)
	)

	var previewing: bool = (
		not pending_component_id.is_empty()
	)

	if previewing:
		assembly_label.text = (
			"%d / 6 PREVIEW" % count
		)

		assembly_label.add_theme_color_override(
			"font_color",
			WARNING
		)

	else:
		assembly_label.text = (
			"%d / 6 PARTS" % count
		)

		assembly_label.add_theme_color_override(
			"font_color",
			GOOD if count == 6
			else WARNING
		)


# ==========================================
# NAVIGATION AND MATCHA
# ==========================================

func _message(message: String) -> void:
	message_label.text = message


func _on_back_pressed() -> void:
	# Discard unconfirmed equipment changes.
	_clear_pending()
	close_requested.emit()
