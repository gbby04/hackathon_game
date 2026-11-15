
extends Control

# ============================================================
# SPACE VAULT - FINAL LAUNCH PREFLIGHT
# Godot 4.7
#
# This is the gate BEFORE the existing launch animation.
#
# Uses:
# - SpacecraftGameState
# - MissionSimulation
# - NASAData via MissionSimulation
# - Existing equipped WORKBENCH components
#
# Does not:
# - Damage Joe
# - Drain battery arbitrarily
# - Change spacecraft statistics
# - Reset progress
# - Replace the original rocket launch animation
#
# IMPORTANT:
# Original EscapeLaunch.tscn should be renamed to
# EscapeLaunchAnimation.tscn.
#
# Save this new Control scene as EscapeLaunch.tscn.
# ============================================================

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const LAUNCH_ANIMATION_PATH: String = (
	"res://scenes/spacecraft/EscapeLaunchAnimation.tscn"
)

const BUILDER_SCENE: PackedScene = preload(
	"res://scenes/spacecraft/ShipBuilder.tscn"
)

const BG: Color = Color("#091524")
const HEADER: Color = Color("#10243a")
const CARD: Color = Color("#162940")
const BORDER: Color = Color("#29445c")

const WHITE: Color = Color("#eaf6ff")
const MUTED: Color = Color("#a5b9cc")
const CYAN: Color = Color("#50d4e8")
const GREEN: Color = Color("#7deda4")
const RED: Color = Color("#ff8a8a")
const YELLOW: Color = Color("#ffca70")

var report: Dictionary = {}
var launch_ready: bool = false
var launching: bool = false

var state_label: Label
var result_labels: Dictionary = {}
var detail_labels: Dictionary = {}

var matcha_label: Label

var launch_button: Button
var recheck_button: Button
var builder_button: Button

var builder: Control = null
var fade_overlay: ColorRect


# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	_build_interface()
	_run_preflight()


# ============================================================
# UI HELPERS
# ============================================================

func _style(
	background_colour: Color,
	border_colour: Color = BORDER
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = background_colour
	style.border_color = border_colour

	style.set_border_width_all(1)
	style.set_corner_radius_all(4)

	return style


func _panel(
	at: Vector2,
	dimensions: Vector2,
	background_colour: Color
) -> Panel:
	var result: Panel = Panel.new()

	result.position = at
	result.size = dimensions

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	result.add_theme_stylebox_override(
		"panel",
		_style(background_colour)
	)

	add_child(result)

	return result


func _label(
	value: String,
	at: Vector2,
	dimensions: Vector2,
	font_size: int,
	colour: Color = WHITE
) -> Label:
	var result: Label = Label.new()

	result.text = value
	result.position = at
	result.size = dimensions

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

	add_child(result)

	return result


func _button(
	value: String,
	at: Vector2,
	dimensions: Vector2,
	primary: bool = false
) -> Button:
	var result: Button = Button.new()

	result.text = value
	result.position = at
	result.size = dimensions
	result.focus_mode = Control.FOCUS_NONE

	result.add_theme_font_size_override(
		"font_size",
		10
	)

	var normal_colour: Color = CARD

	if primary:
		normal_colour = Color("#176f91")

	result.add_theme_stylebox_override(
		"normal",
		_style(normal_colour)
	)

	result.add_theme_stylebox_override(
		"hover",
		_style(Color("#247e9e"), CYAN)
	)

	result.add_theme_stylebox_override(
		"pressed",
		_style(Color("#125773"), CYAN)
	)

	result.add_theme_stylebox_override(
		"disabled",
		_style(Color("#28384a"))
	)

	result.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	for colour_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color"
	]:
		result.add_theme_color_override(
			colour_name,
			WHITE
		)

	result.add_theme_color_override(
		"font_disabled_color",
		MUTED
	)

	add_child(result)

	return result


# ============================================================
# BUILD INTERFACE
# ============================================================

func _build_interface() -> void:
	var background: ColorRect = ColorRect.new()

	background.color = BG

	add_child(background)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Header
	_panel(
		Vector2(8, 8),
		Vector2(624, 57),
		HEADER
	)

	_label(
		"SPACE VAULT // FINAL PREFLIGHT",
		Vector2(19, 17),
		Vector2(420, 24),
		17,
		CYAN
	)

	_label(
		"MATCHA ENGINEERING CONTROL SYSTEM",
		Vector2(20, 44),
		Vector2(405, 13),
		9,
		MUTED
	)

	state_label = _label(
		"",
		Vector2(431, 29),
		Vector2(185, 20),
		11,
		YELLOW
	)

	state_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	# Engineering check container
	_panel(
		Vector2(8, 73),
		Vector2(624, 184),
		CARD
	)

	_make_check_row(
		"equipment",
		"01",
		"ROCKET ASSEMBLY",
		86
	)

	_make_check_row(
		"power",
		"02",
		"ECLIPSE ENDURANCE",
		128
	)

	_make_check_row(
		"launch",
		"03",
		"LAUNCH PERFORMANCE",
		170
	)

	_make_check_row(
		"communications",
		"04",
		"DATA TRANSMISSION",
		212
	)

	# Matcha dialogue
	_panel(
		Vector2(8, 266),
		Vector2(624, 42),
		HEADER
	)

	_label(
		"MATCHA",
		Vector2(18, 275),
		Vector2(67, 18),
		11,
		CYAN
	)

	matcha_label = _label(
		"",
		Vector2(88, 273),
		Vector2(525, 30),
		10,
		WHITE
	)

	# Controls
	builder_button = _button(
		"WORKBENCH",
		Vector2(8, 317),
		Vector2(148, 34)
	)

	recheck_button = _button(
		"RECHECK",
		Vector2(166, 317),
		Vector2(148, 34)
	)

	launch_button = _button(
		"INITIATE LAUNCH",
		Vector2(324, 317),
		Vector2(308, 34),
		true
	)

	builder_button.pressed.connect(
		_open_builder
	)

	recheck_button.pressed.connect(
		_run_preflight
	)

	launch_button.pressed.connect(
		_start_launch
	)

	# Fade overlay
	fade_overlay = ColorRect.new()

	fade_overlay.position = Vector2.ZERO
	fade_overlay.size = SCREEN_SIZE
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(fade_overlay)


# ============================================================
# ENGINEERING CHECK ROW
# ============================================================

func _make_check_row(
	check_id: String,
	number: String,
	title_text: String,
	y: float
) -> void:
	var separator: ColorRect = ColorRect.new()

	separator.position = Vector2(18, y + 37)
	separator.size = Vector2(604, 1)
	separator.color = BORDER

	add_child(separator)

	_label(
		number,
		Vector2(21, y + 7),
		Vector2(26, 23),
		14,
		CYAN
	)

	_label(
		title_text,
		Vector2(52, y),
		Vector2(345, 20),
		12,
		WHITE
	)

	var details: Label = _label(
		"",
		Vector2(52, y + 20),
		Vector2(435, 16),
		9,
		MUTED
	)

	detail_labels[check_id] = details

	var result: Label = _label(
		"",
		Vector2(512, y + 10),
		Vector2(103, 21),
		12,
		YELLOW
	)

	result.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	result_labels[check_id] = result


# ============================================================
# STATUS DISPLAY
# ============================================================

func _set_check(
	check_id: String,
	passed: bool,
	details: String
) -> void:
	var result: Label = (
		result_labels[check_id]
	)

	var detail: Label = (
		detail_labels[check_id]
	)

	result.text = (
		"PASS"
		if passed
		else "FAIL"
	)

	result.add_theme_color_override(
		"font_color",
		GREEN if passed else RED
	)

	detail.text = details


func _short_number(value: float) -> String:
	return "%.1f" % value


# ============================================================
# PREFLIGHT SIMULATION
# ============================================================

func _run_preflight() -> void:
	if launching:
		return

	if is_instance_valid(builder):
		return

	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	var simulation: MissionSimulation = (
		SpacecraftGameState.simulator
	)

	report = simulation.evaluate_mission(stats)

	var equipment_ok: bool = (
		int(stats.get("equipped_count", 0)) >= 6
		and bool(stats.get("complete", false))
	)

	var power: Dictionary = report.get(
		"eclipse",
		{}
	)

	var launch: Dictionary = report.get(
		"launch",
		{}
	)

	var communications: Dictionary = report.get(
		"communications",
		{}
	)

	# When the rocket is incomplete,
	# evaluate_mission returns no sub-results.
	# Evaluate them separately for diagnostic
	# information without granting launch.
	if power.is_empty():
		power = simulation.check_eclipse(
			stats,
			35.0
		)

	if launch.is_empty():
		launch = simulation.check_launch(
			stats,
			500.0
		)

	if communications.is_empty():
		communications = (
			simulation.check_communications(
				stats,
				20.0,
				6.0,
				15.0
			)
		)

	var power_ok: bool = bool(
		power.get("success", false)
	)

	var launch_ok: bool = bool(
		launch.get("success", false)
	)

	var communications_ok: bool = bool(
		communications.get("success", false)
	)

	var bosses_ok: bool = (
		SpacecraftGameState.is_final_escape_unlocked()
	)

	launch_ready = (
		bosses_ok
		and equipment_ok
		and bool(report.get("success", false))
		and power_ok
		and launch_ok
		and communications_ok
	)

	_set_check(
		"equipment",
		equipment_ok,
		"%d of 6 component categories installed"
		% int(stats.get("equipped_count", 0))
	)

	_set_check(
		"power",
		power_ok,
		"%s Wh available / %s Wh required"
		% [
			_short_number(
				float(stats.get("battery_wh", 0.0))
			),
			_short_number(
				float(power.get(
					"energy_required_wh",
					0.0
				))
			)
		]
	)

	_set_check(
		"launch",
		launch_ok,
		"%s kg / 500 kg  |  T/W %s"
		% [
			_short_number(
				float(stats.get("mass_kg", 0.0))
			),
			_short_number(
				float(launch.get(
					"thrust_to_weight",
					0.0
				))
			)
		]
	)

	_set_check(
		"communications",
		communications_ok,
		"%s MB transmitted / 15 MB required"
		% _short_number(
			float(communications.get(
				"transmitted_data_mb",
				0.0
			))
		)
	)

	launch_button.disabled = not launch_ready

	if launch_ready:
		state_label.text = "READY FOR LAUNCH"
		state_label.add_theme_color_override(
			"font_color",
			GREEN
		)

		matcha_label.text = (
			"All baseline engineering checks passed, "
			+ "sir. We are cleared to attempt escape."
		)

	elif not bosses_ok:
		state_label.text = "LAUNCH LOCKED"
		state_label.add_theme_color_override(
			"font_color",
			YELLOW
		)

		matcha_label.text = (
			"Four Scientists must be defeated "
			+ "before launch authorisation, sir."
		)

	elif not equipment_ok:
		state_label.text = "ASSEMBLY REQUIRED"
		state_label.add_theme_color_override(
			"font_color",
			YELLOW
		)

		matcha_label.text = (
			"Your spacecraft is incomplete, sir. "
			+ "Return to WORKBENCH."
		)

	elif not power_ok:
		_set_failure_message(
			"Power endurance failed. Consider "
			+ "a larger battery or lower power demand."
		)

	elif not launch_ok:
		_set_failure_message(
			"Launch requirements failed. Review "
			+ "mass, propulsion, fuel and budget."
		)

	elif not communications_ok:
		_set_failure_message(
			"Communication requirements failed. "
			+ "Upgrade the scanner or radio."
		)

	else:
		_set_failure_message(
			"Engineering verification incomplete. "
			+ "Recheck the spacecraft configuration."
		)


func _set_failure_message(message: String) -> void:
	state_label.text = "REVIEW REQUIRED"

	state_label.add_theme_color_override(
		"font_color",
		RED
	)

	matcha_label.text = "MATCHA: " + message


# ============================================================
# WORKBENCH
# ============================================================

func _open_builder() -> void:
	if launching:
		return

	if is_instance_valid(builder):
		return

	builder = BUILDER_SCENE.instantiate() as Control

	if builder == null:
		push_error(
			"ShipBuilder.tscn requires a Control root."
		)
		return

	add_child(builder)

	builder.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	builder.move_to_front()

	if builder.has_signal("close_requested"):
		builder.connect(
			"close_requested",
			_close_builder
		)


func _close_builder() -> void:
	if is_instance_valid(builder):
		builder.queue_free()

	builder = null

	# Recalculate based on newly installed
	# spacecraft components.
	_run_preflight()


# ============================================================
# FINAL LAUNCH
# ============================================================

func _start_launch() -> void:
	if launching:
		return

	# Always verify again when the player
	# actually presses INITIATE LAUNCH.
	_run_preflight()

	if not launch_ready:
		return

	if not ResourceLoader.exists(
		LAUNCH_ANIMATION_PATH
	):
		push_error(
			"Missing original launch scene: "
			+ LAUNCH_ANIMATION_PATH
		)

		matcha_label.text = (
			"MATCHA: Launch animation scene missing, sir."
		)
		return

	launching = true

	builder_button.disabled = true
	recheck_button.disabled = true
	launch_button.disabled = true

	matcha_label.text = (
		"MATCHA: Preflight complete. "
		+ "Beginning escape sequence."
	)

	fade_overlay.move_to_front()

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	var tween: Tween = create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		0.7
	)

	await tween.finished

	get_tree().change_scene_to_file(
		LAUNCH_ANIMATION_PATH
	)
