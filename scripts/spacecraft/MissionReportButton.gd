extends Button

# ==========================================================
# SPACE VAULT - MISSION REPORT BUTTON
# Godot 4.7
#
# Clean alignment version:
# - REPORT matches BACK size and vertical position
# - Opens Mission Readiness as overlay
# - Returns cleanly back to Ship Builder
# ==========================================================

const REPORT_SCRIPT_PATH: String = (
	"res://scripts/spacecraft/MissionReadinessReport.gd"
)

const BUTTON_BG: Color = Color("#176f91")
const BUTTON_HOVER: Color = Color("#278eae")
const BUTTON_BORDER: Color = Color("#50d4e8")

var report_overlay: Control = null

func _ready() -> void:
	name = "MissionReportButton"
	text = "REPORT"

	# Aligned to match BACK button in ShipBuilder.gd
	# BACK = position (522, 17), size (98, 31)
	# Keep an 8px gap between REPORT and BACK
	position = Vector2(416, 17)
	size = Vector2(98, 31)

	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP

	add_theme_font_size_override("font_size", 10)

	for colour_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
		"font_focus_color"
	]:
		add_theme_color_override(
			colour_name,
			Color.WHITE
		)

	add_theme_stylebox_override(
		"normal",
		_make_style(BUTTON_BG)
	)

	add_theme_stylebox_override(
		"hover",
		_make_style(BUTTON_HOVER)
	)

	add_theme_stylebox_override(
		"pressed",
		_make_style(BUTTON_HOVER)
	)

	add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	pressed.connect(_open_report)

	call_deferred("_bring_to_front")

func _bring_to_front() -> void:
	if not is_inside_tree():
		return

	move_to_front()

func _make_style(
	background_colour: Color
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = background_colour
	style.border_color = BUTTON_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)

	return style

# ==========================================================
# OPEN MISSION REPORT
# ==========================================================

func _open_report() -> void:
	if is_instance_valid(report_overlay):
		return

	if not ResourceLoader.exists(REPORT_SCRIPT_PATH):
		push_error(
			"Mission Report script missing: "
			+ REPORT_SCRIPT_PATH
		)
		return

	var parent_control: Control = (
		get_parent() as Control
	)

	if parent_control == null:
		push_error(
			"MissionReportButton must be a direct "
			+ "child of the ShipBuilder root."
		)
		return

	var report_script: Script = (
		load(REPORT_SCRIPT_PATH) as Script
	)

	if report_script == null:
		push_error(
			"Could not load MissionReadinessReport.gd"
		)
		return

	var report_object: Object = report_script.new()

	if not report_object is Control:
		push_error(
			"MissionReadinessReport.gd must extend Control."
		)

		if report_object != null:
			report_object.free()

		return

	report_overlay = Control.new()
	report_overlay.name = "MissionReportOverlay"
	report_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	parent_control.add_child(report_overlay)

	report_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	report_overlay.move_to_front()

	var report: Control = report_object as Control
	report.name = "MissionReadinessReport"

	report_overlay.add_child(report)

	report.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_add_close_button(report)

# ==========================================================
# REPORT HEADER BACK BUTTON
# ==========================================================

func _add_close_button(report: Control) -> void:
	var refresh_control: Variant = report.get("refresh_button")

	if not refresh_control is Button:
		push_error(
			"Mission Report refresh button was not created."
		)
		return

	var refresh_button: Button = refresh_control as Button

	var header: HBoxContainer = (
		refresh_button.get_parent() as HBoxContainer
	)

	if header == null:
		push_error(
			"Mission Report header was not found."
		)
		return

	var close_button: Button = Button.new()

	close_button.name = "CloseMissionReport"
	close_button.text = "BACK"
	close_button.custom_minimum_size = Vector2(88, 32)
	close_button.focus_mode = Control.FOCUS_NONE

	close_button.add_theme_font_size_override(
		"font_size",
		10
	)

	close_button.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	close_button.add_theme_color_override(
		"font_hover_color",
		Color.WHITE
	)

	close_button.add_theme_stylebox_override(
		"normal",
		_make_style(BUTTON_BG)
	)

	close_button.add_theme_stylebox_override(
		"hover",
		_make_style(BUTTON_HOVER)
	)

	close_button.add_theme_stylebox_override(
		"pressed",
		_make_style(BUTTON_HOVER)
	)

	close_button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	close_button.pressed.connect(_close_report)

	header.add_child(close_button)

# ==========================================================
# CLOSE REPORT
# ==========================================================

func _close_report() -> void:
	if not is_instance_valid(report_overlay):
		return

	report_overlay.queue_free()
	report_overlay = null

	call_deferred("_bring_to_front")
