
extends Control

# ============================================================
# SPACE VAULT - MISSION CONTROL
# Godot 4.7
#
# A game-style engineering report.
#
# FEATURES
# - Compact 640x360 mission-control layout
# - Rocket assembly preview
# - Preview reflects equipped component categories
# - Four interactive Scientist checks
# - Detailed measurements on click
# - Matcha advice always visible
# - Refresh after equipment changes
# - Uses the existing MissionSimulation
# - Uses the existing NASAData reference
# - Does not alter equipment or progression
#
# Compatible with MissionReportButton.gd:
# The existing button adds BACK beside refresh_button.
# ============================================================

const SCREEN: Vector2 = Vector2(640, 360)

const BG: Color = Color("#091524")
const HEADER: Color = Color("#10243a")
const CARD: Color = Color("#162940")
const CARD_HOVER: Color = Color("#203b55")
const BORDER: Color = Color("#29445c")

const WHITE: Color = Color("#eaf6ff")
const MUTED: Color = Color("#a5b9cc")
const ACCENT: Color = Color("#50d4e8")
const GOOD: Color = Color("#7deda4")
const WARNING: Color = Color("#ffca70")
const BAD: Color = Color("#ff8a8a")

# These are existing simplified game scenarios.
# They are NOT presented as NASA mission specifications.
const ECLIPSE_MINUTES: float = 35.0
const MASS_LIMIT_KG: float = 500.0
const OBSERVATION_MINUTES: float = 20.0
const CONTACT_MINUTES: float = 6.0
const REQUIRED_DATA_MB: float = 15.0

const REQUIRED_CATEGORIES: Array[String] = [
	"engine",
	"battery",
	"solar",
	"scanner",
	"communication",
	"fuel"
]

const CATEGORY_NAMES: Dictionary = {
	"engine": "Engine",
	"battery": "Battery",
	"solar": "Solar panel",
	"scanner": "Science scanner",
	"communication": "Radio",
	"fuel": "Fuel tank"
}

# ============================================================
# ROCKET PREVIEW
# ============================================================

class RocketDisplay:
	extends Control

	var equipment: Dictionary = {}

	var line_colour: Color = Color("#5e91ad")
	var active_colour: Color = Color("#50d4e8")
	var rocket_fill: Color = Color("#203b53")
	var inactive_colour: Color = Color("#29445c")

	func set_equipment(value: Dictionary) -> void:
		equipment = value.duplicate(true)
		queue_redraw()

	func _equipped(category: String) -> bool:
		return not str(
			equipment.get(category, "")
		).is_empty()

	func _draw() -> void:
		# Engineering grid
		for x in range(13, 163, 15):
			draw_line(
				Vector2(x, 2),
				Vector2(x, 170),
				Color("#214057", 0.28),
				1.0
			)

		for y in range(9, 168, 15):
			draw_line(
				Vector2(9, y),
				Vector2(166, y),
				Color("#214057", 0.28),
				1.0
			)

		# Centre guide
		draw_line(
			Vector2(88, 4),
			Vector2(88, 170),
			Color("#41647a", 0.4),
			1.0
		)

		# Rocket body
		var body_outline: PackedVector2Array = (
			PackedVector2Array([
				Vector2(88, 10),
				Vector2(110, 43),
				Vector2(110, 129),
				Vector2(66, 129),
				Vector2(66, 43)
			])
		)

		draw_colored_polygon(
			body_outline,
			rocket_fill
		)

		draw_polyline(
			PackedVector2Array([
				Vector2(88, 10),
				Vector2(110, 43),
				Vector2(110, 129),
				Vector2(66, 129),
				Vector2(66, 43),
				Vector2(88, 10)
			]),
			line_colour,
			2.0,
			true
		)

		# Nose / solar indicator
		if _equipped("solar"):
			draw_line(
				Vector2(88, 11),
				Vector2(88, 43),
				active_colour,
				2.0
			)

		# Fins
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(66, 99),
				Vector2(42, 136),
				Vector2(66, 123)
			]),
			rocket_fill
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(110, 99),
				Vector2(134, 136),
				Vector2(110, 123)
			]),
			rocket_fill
		)

		draw_polyline(
			PackedVector2Array([
				Vector2(66, 99),
				Vector2(42, 136),
				Vector2(66, 123)
			]),
			line_colour,
			2.0
		)

		draw_polyline(
			PackedVector2Array([
				Vector2(110, 99),
				Vector2(134, 136),
				Vector2(110, 123)
			]),
			line_colour,
			2.0
		)

		# Science instrument window
		var scanner_colour: Color = (
			active_colour
			if _equipped("scanner")
			else inactive_colour
		)

		draw_rect(
			Rect2(78, 51, 20, 19),
			scanner_colour,
			false,
			2.0
		)

		# Communications aerial
		if _equipped("communication"):
			draw_line(
				Vector2(110, 65),
				Vector2(124, 52),
				active_colour,
				2.0
			)
			draw_circle(
				Vector2(125, 51),
				3.0,
				active_colour
			)

		# Battery indicator
		draw_rect(
			Rect2(78, 79, 20, 13),
			(
				active_colour
				if _equipped("battery")
				else inactive_colour
			),
			false,
			2.0
		)

		# Fuel section
		draw_rect(
			Rect2(73, 100, 30, 18),
			(
				Color("#46677c")
				if _equipped("fuel")
				else inactive_colour
			),
			true
		)

		# Engine
		draw_rect(
			Rect2(77, 129, 22, 11),
			(
				active_colour
				if _equipped("engine")
				else line_colour
			),
			false,
			2.0
		)

		# Engine flame when installed
		if _equipped("engine"):
			draw_colored_polygon(
				PackedVector2Array([
					Vector2(81, 141),
					Vector2(88, 159),
					Vector2(95, 141)
				]),
				WARNING
			)


# ============================================================
# STATE
# ============================================================

var nasa: NASAData = NASAData.new()

var current_stats: Dictionary = {}
var current_equipment: Dictionary = {}
var check_results: Dictionary = {}

var refresh_button: Button
var status_label: Label
var assembly_label: Label
var assembly_bar: ColorRect
var rocket_display: RocketDisplay

var matcha_label: Label
var checks_container: Control

var detail_overlay: Control = null

var current_check: String = ""


# ============================================================
# START
# ============================================================

func _ready() -> void:
	custom_minimum_size = SCREEN

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	_build_interface()
	_refresh_report()


# ============================================================
# STYLE HELPERS
# ============================================================

func _style(
	colour: Color,
	border_colour: Color = BORDER
) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()

	result.bg_color = colour
	result.border_color = border_colour

	result.set_border_width_all(1)
	result.set_corner_radius_all(4)

	return result


func _panel(
	parent_node: Node,
	rect: Rect2,
	colour: Color,
	border_colour: Color = BORDER
) -> Panel:
	var result: Panel = Panel.new()

	result.position = rect.position
	result.size = rect.size

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	result.add_theme_stylebox_override(
		"panel",
		_style(colour, border_colour)
	)

	parent_node.add_child(result)

	return result


func _label(
	parent_node: Node,
	value: String,
	rect: Rect2,
	font_size: int,
	colour: Color = WHITE
) -> Label:
	var result: Label = Label.new()

	result.text = value
	result.position = rect.position
	result.size = rect.size

	result.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	result.add_theme_font_size_override(
		"font_size",
		font_size
	)

	result.add_theme_color_override(
		"font_color",
		colour
	)

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	parent_node.add_child(result)

	return result


func _button_style(
	colour: Color
) -> StyleBoxFlat:
	return _style(
		colour,
		ACCENT
	)


func _make_button(
	value: String,
	width_value: float = 76.0
) -> Button:
	var result: Button = Button.new()

	result.text = value

	result.custom_minimum_size = Vector2(
		width_value,
		29
	)

	result.focus_mode = Control.FOCUS_NONE

	result.add_theme_font_size_override(
		"font_size",
		10
	)

	for name_value in [
		"font_color",
		"font_hover_color",
		"font_pressed_color"
	]:
		result.add_theme_color_override(
			name_value,
			WHITE
		)

	result.add_theme_stylebox_override(
		"normal",
		_button_style(Color("#176f91"))
	)

	result.add_theme_stylebox_override(
		"hover",
		_button_style(Color("#278eae"))
	)

	result.add_theme_stylebox_override(
		"pressed",
		_button_style(Color("#135470"))
	)

	result.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	return result


# ============================================================
# LAYOUT
# ============================================================

func _build_interface() -> void:
	# Background
	var background: ColorRect = ColorRect.new()

	background.color = BG
	background.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(background)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Header
	_panel(
		self,
		Rect2(8, 7, 624, 47),
		HEADER
	)

	var header: HBoxContainer = HBoxContainer.new()

	header.position = Vector2(17, 13)
	header.size = Vector2(605, 35)

	header.add_theme_constant_override(
		"separation",
		8
	)

	add_child(header)

	var title_box: VBoxContainer = VBoxContainer.new()

	title_box.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	title_box.add_theme_constant_override(
		"separation",
		1
	)

	header.add_child(title_box)

	var title_label: Label = Label.new()

	title_label.text = "MISSION CONTROL"

	title_label.add_theme_font_size_override(
		"font_size",
		17
	)

	title_label.add_theme_color_override(
		"font_color",
		ACCENT
	)

	title_box.add_child(title_label)

	var subtitle: Label = Label.new()

	subtitle.text = "SPACE VAULT / ENGINEERING DIAGNOSTICS"

	subtitle.add_theme_font_size_override(
		"font_size",
		8
	)

	subtitle.add_theme_color_override(
		"font_color",
		MUTED
	)

	title_box.add_child(subtitle)

	# Existing MissionReportButton.gd expects
	# refresh_button inside an HBoxContainer.
	refresh_button = _make_button(
		"REFRESH",
		76.0
	)

	header.add_child(refresh_button)

	refresh_button.pressed.connect(
		_refresh_report
	)

	# Readiness line
	status_label = _label(
		self,
		"AWAITING ASSEMBLY",
		Rect2(15, 60, 605, 18),
		10,
		WARNING
	)

	# Rocket panel
	_panel(
		self,
		Rect2(8, 82, 267, 218),
		CARD
	)

	_label(
		self,
		"SPACECRAFT ASSEMBLY",
		Rect2(19, 92, 245, 20),
		12,
		ACCENT
	)

	rocket_display = RocketDisplay.new()

	rocket_display.position = Vector2(
		16,
		114
	)

	rocket_display.size = Vector2(
		176,
		172
	)

	rocket_display.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(rocket_display)

	# Right side of rocket panel
	assembly_label = _label(
		self,
		"0 / 6",
		Rect2(179, 125, 85, 32),
		20,
		WHITE
	)

	_label(
		self,
		"COMPONENTS",
		Rect2(179, 156, 85, 16),
		8,
		MUTED
	)

	# Progress track
	var progress_track: ColorRect = ColorRect.new()

	progress_track.position = Vector2(181, 183)
	progress_track.size = Vector2(76, 6)
	progress_track.color = Color("#29445c")

	add_child(progress_track)

	assembly_bar = ColorRect.new()

	assembly_bar.position = Vector2(181, 183)
	assembly_bar.size = Vector2(0, 6)
	assembly_bar.color = ACCENT

	add_child(assembly_bar)

	_label(
		self,
		"BUILT FROM",
		Rect2(181, 210, 80, 13),
		8,
		MUTED
	)

	_label(
		self,
		"WORKBENCH",
		Rect2(181, 225, 82, 17),
		10,
		ACCENT
	)

	_label(
		self,
		"6 REQUIRED\nSYSTEMS",
		Rect2(181, 251, 80, 31),
		9,
		MUTED
	)

	# Scientist checks
	checks_container = Control.new()

	checks_container.position = Vector2(
		285,
		82
	)

	checks_container.size = Vector2(
		347,
		218
	)

	add_child(checks_container)

	# Bottom Matcha panel
	_panel(
		self,
		Rect2(8, 307, 624, 45),
		HEADER
	)

	_label(
		self,
		"MATCHA",
		Rect2(18, 312, 67, 14),
		10,
		ACCENT
	)

	matcha_label = _label(
		self,
		"",
		Rect2(86, 313, 533, 31),
		10,
		WHITE
	)


# ============================================================
# EQUIPMENT HELPERS
# ============================================================

func _has_part(category: String) -> bool:
	return not str(
		current_equipment.get(category, "")
	).is_empty()


func _has_parts(categories: Array[String]) -> bool:
	for category in categories:
		if not _has_part(category):
			return false

	return true


func _missing_parts(categories: Array[String]) -> String:
	var missing: Array[String] = []

	for category in categories:
		if not _has_part(category):
			missing.append(
				str(CATEGORY_NAMES.get(
					category,
					category
				))
			)

	return ", ".join(missing)


func _check_state(
	ready_to_test: bool,
	result: Dictionary
) -> String:
	if not ready_to_test:
		return "NOT TESTED"

	if not bool(result.get("valid", true)):
		return "UNAVAILABLE"

	return (
		"PASS"
		if bool(result.get("success", false))
		else "FAIL"
	)


func _state_colour(state: String) -> Color:
	match state:
		"PASS":
			return GOOD

		"FAIL":
			return BAD

		"UNAVAILABLE":
			return BAD

		_:
			return WARNING


# ============================================================
# REFRESH FROM WORKBENCH
# ============================================================

func _refresh_report() -> void:
	if is_instance_valid(detail_overlay):
		detail_overlay.queue_free()
		detail_overlay = null

	current_stats = (
		SpacecraftGameState.get_ship_stats()
	)

	current_equipment = (
		SpacecraftGameState.get_equipped_components()
	)

	var simulation: MissionSimulation = (
		MissionSimulation.new()
	)

	var power_result: Dictionary = (
		simulation.check_eclipse(
			current_stats,
			ECLIPSE_MINUTES
		)
	)

	var launch_result: Dictionary = (
		simulation.check_launch(
			current_stats,
			MASS_LIMIT_KG
		)
	)

	var comm_result: Dictionary = (
		simulation.check_communications(
			current_stats,
			OBSERVATION_MINUTES,
			CONTACT_MINUTES,
			REQUIRED_DATA_MB
		)
	)

	var power_ready: bool = _has_parts(
		["battery"]
	)

	power_ready = (
		power_ready
		and float(
			current_stats.get("power_w", 0.0)
		) > 0.0
	)

	var launch_ready: bool = _has_parts(
		["engine", "fuel"]
	)

	var comm_ready: bool = _has_parts(
		["scanner", "communication"]
	)

	var complete: bool = bool(
		current_stats.get("complete", false)
	)

	var power_state: String = _check_state(
		power_ready,
		power_result
	)

	var launch_state: String = _check_state(
		launch_ready,
		launch_result
	)

	var comm_state: String = _check_state(
		comm_ready,
		comm_result
	)

	var final_success: bool = (
		complete
		and power_state == "PASS"
		and launch_state == "PASS"
		and comm_state == "PASS"
	)

	var final_state: String = "LOCKED"

	if complete:
		final_state = (
			"PASS"
			if final_success
			else "FAIL"
		)

	check_results = {
		"niq": {
			"state": power_state,
			"result": power_result,
			"ready": power_ready
		},
		"gabby": {
			"state": launch_state,
			"result": launch_result,
			"ready": launch_ready
		},
		"ahmed": {
			"state": comm_state,
			"result": comm_result,
			"ready": comm_ready
		},
		"celine": {
			"state": final_state,
			"result": {},
			"ready": complete
		}
	}

	var count: int = int(
		current_stats.get("equipped_count", 0)
	)

	assembly_label.text = "%d / 6" % count

	assembly_bar.size.x = (
		76.0 * clampf(
			float(count) / 6.0,
			0.0,
			1.0
		)
	)

	rocket_display.set_equipment(
		current_equipment
	)

	if count == 0:
		status_label.text = (
			"AWAITING ASSEMBLY  /  INSTALL YOUR FIRST COMPONENT"
		)
		status_label.add_theme_color_override(
			"font_color",
			WARNING
		)

	elif final_success:
		status_label.text = (
			"BASELINE ENGINEERING CHECKS PASSED"
		)
		status_label.add_theme_color_override(
			"font_color",
			GOOD
		)

	elif not complete:
		status_label.text = (
			"ASSEMBLY INCOMPLETE  /  %d OF 6 COMPONENTS"
			% count
		)
		status_label.add_theme_color_override(
			"font_color",
			WARNING
		)

	else:
		status_label.text = (
			"ENGINEERING REVIEW REQUIRED"
		)
		status_label.add_theme_color_override(
			"font_color",
			BAD
		)

	_build_check_buttons()
	_update_matcha_message(final_success)


# ============================================================
# FOUR INTERACTIVE SCIENTIST CHECKS
# ============================================================

func _build_check_buttons() -> void:
	for child in checks_container.get_children():
		checks_container.remove_child(child)
		child.queue_free()

	_add_check(
		"niq",
		"01",
		"POWER SYSTEM",
		"DR. NIQ  /  ECLIPSE",
		0
	)

	_add_check(
		"gabby",
		"02",
		"LAUNCH SYSTEM",
		"DR. GABBY  /  PAYLOAD",
		55
	)

	_add_check(
		"ahmed",
		"03",
		"COMMUNICATIONS",
		"DR. AHMED  /  DOWNLINK",
		110
	)

	_add_check(
		"celine",
		"04",
		"FINAL SYSTEM CHECK",
		"DR. CELINE  /  COMBINED",
		165
	)


func _add_check(
	check_id: String,
	number: String,
	name_value: String,
	subtitle: String,
	y: float
) -> void:
	var state: String = str(
		check_results[check_id].get(
			"state",
			"NOT TESTED"
		)
	)

	var colour: Color = _state_colour(state)

	var holder: Control = Control.new()

	holder.position = Vector2(0, y)
	holder.size = Vector2(347, 51)

	checks_container.add_child(holder)

	var button: Button = Button.new()

	button.position = Vector2.ZERO
	button.size = Vector2(347, 51)
	button.text = ""

	button.focus_mode = Control.FOCUS_NONE

	button.add_theme_stylebox_override(
		"normal",
		_style(CARD)
	)

	button.add_theme_stylebox_override(
		"hover",
		_style(CARD_HOVER, ACCENT)
	)

	button.add_theme_stylebox_override(
		"pressed",
		_style(HEADER, ACCENT)
	)

	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	holder.add_child(button)

	button.pressed.connect(
		_show_details.bind(check_id)
	)

	# Decorative content is mouse-transparent so
	# clicking anywhere activates the parent button.
	_label(
		holder,
		number,
		Rect2(12, 13, 28, 24),
		17,
		colour
	)

	_label(
		holder,
		name_value,
		Rect2(45, 8, 200, 19),
		12,
		WHITE
	)

	_label(
		holder,
		subtitle,
		Rect2(45, 28, 220, 16),
		9,
		MUTED
	)

	var state_text: Label = _label(
		holder,
		state,
		Rect2(239, 17, 94, 20),
		10,
		colour
	)

	state_text.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)


# ============================================================
# MATCHA MESSAGE
# ============================================================

func _update_matcha_message(
	final_success: bool
) -> void:
	var count: int = int(
		current_stats.get("equipped_count", 0)
	)

	if count == 0:
		matcha_label.text = (
			"Sir, we have a launch plan, but no rocket. "
			+ "Install some components first."
		)
		return

	if count < 6:
		matcha_label.text = (
			"%d of 6 systems installed, sir. "
			% count
		) + (
			"Complete the assembly before our final review."
		)
		return

	if final_success:
		matcha_label.text = (
			"Baseline tests passed, sir. "
			+ "Scientist debuffs may still require countermeasures."
		)
		return

	for check_id in ["niq", "gabby", "ahmed"]:
		if str(
			check_results[check_id].get("state", "")
		) != "PASS":
			matcha_label.text = (
				"An engineering weakness remains, sir. "
				+ "Select a highlighted system for recommendations."
			)
			return


# ============================================================
# DETAIL WINDOW
# ============================================================

func _show_details(check_id: String) -> void:
	if is_instance_valid(detail_overlay):
		return

	current_check = check_id

	detail_overlay = Control.new()
	detail_overlay.name = "EngineeringDetails"

	add_child(detail_overlay)

	detail_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	detail_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	detail_overlay.move_to_front()

	var dimmer: ColorRect = ColorRect.new()

	dimmer.color = Color(
		0.01,
		0.03,
		0.06,
		0.84
	)

	dimmer.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	detail_overlay.add_child(dimmer)

	dimmer.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_panel(
		detail_overlay,
		Rect2(55, 49, 530, 262),
		CARD,
		ACCENT
	)

	var title: String = ""

	match check_id:
		"niq":
			title = "POWER / ECLIPSE"

		"gabby":
			title = "LAUNCH / PAYLOAD"

		"ahmed":
			title = "COMMUNICATIONS / DOWNLINK"

		"celine":
			title = "FINAL / SYSTEM REVIEW"

	_label(
		detail_overlay,
		title,
		Rect2(72, 63, 395, 25),
		16,
		ACCENT
	)

	var close_button: Button = _make_button(
		"CLOSE",
		81.0
	)

	close_button.position = Vector2(
		483,
		61
	)

	close_button.size = Vector2(
		81,
		29
	)

	detail_overlay.add_child(close_button)

	close_button.pressed.connect(
		_close_details
	)

	var check: Dictionary = check_results.get(
		check_id,
		{}
	)

	var state: String = str(
		check.get("state", "NOT TESTED")
	)

	_label(
		detail_overlay,
		"STATUS: " + state,
		Rect2(73, 99, 455, 18),
		12,
		_state_colour(state)
	)

	var explanation: String = _detail_text(
		check_id
	)

	_label(
		detail_overlay,
		explanation,
		Rect2(74, 125, 490, 151),
		11,
		WHITE
	)

	_label(
		detail_overlay,
		"NASA REFERENCE + SIMPLIFIED GAME ENGINEERING",
		Rect2(74, 288, 485, 16),
		9,
		MUTED
	)


func _detail_text(check_id: String) -> String:
	var check: Dictionary = check_results.get(
		check_id,
		{}
	)

	var result: Dictionary = check.get(
		"result",
		{}
	)

	var ready: bool = bool(
		check.get("ready", false)
	)

	var text_value: String = ""

	match check_id:
		"niq":
			if not ready:
				return (
					"Install a battery and powered equipment "
					+ "to test eclipse endurance.\n\n"
					+ "Missing: "
					+ _missing_parts(["battery"])
					+ "\n\nMATCHA: No meaningful power test "
					+ "can be completed yet."
				)

			text_value = (
				"Eclipse duration: %.0f minutes\n"
				+ "Battery capacity: %.1f Wh\n"
				+ "Power demand: %.1f W\n"
				+ "Energy required: %.1f Wh\n"
				+ "Battery remaining: %.1f Wh\n\n"
				+ "%s"
			) % [
				ECLIPSE_MINUTES,
				float(current_stats.get("battery_wh", 0.0)),
				float(current_stats.get("power_w", 0.0)),
				float(result.get("energy_required_wh", 0.0)),
				float(result.get("battery_remaining_wh", 0.0)),
				str(result.get("explanation", ""))
			]

		"gabby":
			if not ready:
				return (
					"Install an engine and fuel tank "
					+ "to test launch performance.\n\n"
					+ "Missing: "
					+ _missing_parts(["engine", "fuel"])
					+ "\n\nMATCHA: Thrust cannot be evaluated "
					+ "without propulsion."
				)

			text_value = (
				"Spacecraft mass: %.1f kg\n"
				+ "Gameplay mass limit: %.0f kg\n"
				+ "Engine thrust: %.1f kN\n"
				+ "Thrust-to-weight ratio: %.2f\n"
				+ "Earth gravity reference: %.2f m/s²\n\n"
				+ "%s"
			) % [
				float(current_stats.get("mass_kg", 0.0)),
				MASS_LIMIT_KG,
				float(current_stats.get("thrust_kn", 0.0)),
				float(result.get("thrust_to_weight", 0.0)),
				nasa.get_surface_gravity(),
				str(result.get("explanation", ""))
			]

		"ahmed":
			if not ready:
				return (
					"Install a science scanner and radio "
					+ "to test communication performance.\n\n"
					+ "Missing: "
					+ _missing_parts([
						"scanner",
						"communication"
					])
					+ "\n\nMATCHA: We need both data "
					+ "collection and transmission."
				)

			text_value = (
				"Observation: %.0f minutes\n"
				+ "Ground contact: %.0f minutes\n"
				+ "Science data: %.1f MB/min\n"
				+ "Downlink: %.1f MB/min\n"
				+ "Delivered: %.1f / %.1f MB\n\n"
				+ "%s"
			) % [
				OBSERVATION_MINUTES,
				CONTACT_MINUTES,
				float(current_stats.get(
					"science_data_mb_per_min",
					0.0
				)),
				float(current_stats.get(
					"downlink_mb_per_min",
					0.0
				)),
				float(result.get(
					"transmitted_data_mb",
					0.0
				)),
				REQUIRED_DATA_MB,
				str(result.get("explanation", ""))
			]

		"celine":
			var assembled: int = int(
				current_stats.get("equipped_count", 0)
			)

			var passed: int = 0

			for id_value in ["niq", "gabby", "ahmed"]:
				if str(
					check_results[id_value].get("state", "")
				) == "PASS":
					passed += 1

			text_value = (
				"Installed components: %d / 6\n"
				+ "Baseline checks passed: %d / 3\n\n"
				+ "POWER: %s\n"
				+ "LAUNCH: %s\n"
				+ "COMMUNICATIONS: %s\n\n"
				+ "This report shows baseline readiness. "
				+ "Dr. Celine's battle applies additional "
				+ "engineering debuffs."
			) % [
				assembled,
				passed,
				str(check_results["niq"]["state"]),
				str(check_results["gabby"]["state"]),
				str(check_results["ahmed"]["state"])
			]

	return text_value


func _close_details() -> void:
	if not is_instance_valid(detail_overlay):
		return

	detail_overlay.queue_free()
	detail_overlay = null
