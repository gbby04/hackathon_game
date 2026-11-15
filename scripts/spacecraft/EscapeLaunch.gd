
extends Control

# ==========================================
# SPACE VAULT - ESCAPE LAUNCH
# Godot 4.7
#
# STEP 26
#
# Features:
# - Final spacecraft launch scene
# - Four Scientist progression check
# - Six-component assembly check
# - Real engineering simulation checks
# - Rocket launch animation
# - Earth launch environment
# - Matcha dialogue
# - Victory sequence
#
# No extra art assets required.
#
# This script creates its own UI.
# Attach it to a Control root node.
# ==========================================

signal launch_completed
signal back_requested

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const BG: Color = Color("#081322")
const PANEL: Color = Color("#12273a")
const BORDER: Color = Color("#33566b")
const TEXT: Color = Color("#e9f7ff")
const MUTED: Color = Color("#a8bdca")
const ACCENT: Color = Color("#5bd6e8")
const GREEN: Color = Color("#83e6aa")
const RED: Color = Color("#ff9090")
const YELLOW: Color = Color("#ffcf78")

var launch_height: float = 0.0:
	set(value):
		launch_height = value
		queue_redraw()

var flame_strength: float = 0.0:
	set(value):
		flame_strength = value
		queue_redraw()

var launching: bool = false
var mission_complete: bool = false
var launch_ready: bool = false

var checks: Dictionary = {}

var title_label: Label
var status_label: Label
var matcha_label: Label

var power_label: Label
var launch_label: Label
var comms_label: Label
var assembly_label: Label
var progress_label: Label

var launch_button: Button
var back_button: Button

var stars: Array[Vector2] = []


# ==========================================
# INITIALISATION
# ==========================================

func _ready() -> void:

	custom_minimum_size = SCREEN_SIZE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_generate_stars()
	_build_interface()
	_refresh_checks()

	queue_redraw()


# ==========================================
# STARS
# ==========================================

func _generate_stars() -> void:

	stars.clear()

	var random := RandomNumberGenerator.new()
	random.seed = 26042026

	for i in range(55):

		var point := Vector2(
			random.randf_range(5.0, 630.0),
			random.randf_range(8.0, 235.0)
		)

		stars.append(point)


# ==========================================
# DRAW LAUNCH ENVIRONMENT
# ==========================================

func _draw() -> void:

	# Sky
	draw_rect(
		Rect2(0, 0, 640, 360),
		BG
	)

	# Upper atmosphere
	draw_rect(
		Rect2(0, 0, 640, 115),
		Color("#0d1d38")
	)

	draw_rect(
		Rect2(0, 115, 640, 95),
		Color("#142c47")
	)

	draw_rect(
		Rect2(0, 210, 640, 100),
		Color("#25445a")
	)

	# Stars
	for star in stars:

		draw_circle(
			star,
			1.2,
			Color("#d7f3ff", 0.75)
		)

	# Moon
	draw_circle(
		Vector2(61, 48),
		22,
		Color("#dce7e9")
	)

	draw_circle(
		Vector2(53, 43),
		5,
		Color("#b7c9d0", 0.65)
	)

	draw_circle(
		Vector2(70, 53),
		3,
		Color("#b7c9d0", 0.65)
	)

	# Distant mountains
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 279),
			Vector2(65, 241),
			Vector2(123, 278),
			Vector2(207, 232),
			Vector2(292, 279),
			Vector2(370, 256),
			Vector2(445, 288),
			Vector2(640, 270),
			Vector2(640, 360),
			Vector2(0, 360)
		]),
		Color("#182e40")
	)

	# Ground
	draw_rect(
		Rect2(0, 291, 640, 69),
		Color("#263e4e")
	)

	draw_rect(
		Rect2(0, 291, 640, 4),
		Color("#466c78")
	)

	# Launch platform
	draw_rect(
		Rect2(62, 292, 216, 16),
		Color("#637986")
	)

	draw_rect(
		Rect2(76, 308, 188, 11),
		Color("#394f62")
	)

	# Launch tower
	draw_rect(
		Rect2(48, 116, 14, 176),
		Color("#405a70")
	)

	for i in range(7):

		var y: float = (
			135.0 + float(i) * 23.0
		)

		draw_line(
			Vector2(49, y),
			Vector2(61, y + 20),
			Color("#8099a7"),
			2.0
		)

		draw_line(
			Vector2(61, y),
			Vector2(49, y + 20),
			Color("#8099a7"),
			2.0
		)

	# Rocket animation
	draw_set_transform(
		Vector2(0.0, -launch_height),
		0.0,
		Vector2.ONE
	)

	_draw_rocket()

	draw_set_transform(
		Vector2.ZERO,
		0.0,
		Vector2.ONE
	)


# ==========================================
# ROCKET DRAWING
# ==========================================

func _draw_rocket() -> void:

	var cx: float = 170.0

	var hull: Color = Color("#d6ecf1")
	var shadow: Color = Color("#779eaf")
	var highlight: Color = Color("#ffffff")

	# Rocket nose
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx, 137),
			Vector2(cx - 23, 178),
			Vector2(cx + 23, 178)
		]),
		hull
	)

	draw_line(
		Vector2(cx, 137),
		Vector2(cx - 23, 178),
		highlight,
		2.0
	)

	# Main body
	draw_rect(
		Rect2(cx - 23, 178, 46, 88),
		hull
	)

	# Hull highlight
	draw_rect(
		Rect2(cx - 17, 178, 9, 88),
		highlight
	)

	# Hull shadow
	draw_rect(
		Rect2(cx + 13, 178, 10, 88),
		shadow
	)

	# Rocket markings
	draw_rect(
		Rect2(cx - 23, 194, 46, 9),
		Color("#43bed1")
	)

	draw_rect(
		Rect2(cx - 23, 239, 46, 7),
		Color("#436f91")
	)

	# Observation window
	draw_circle(
		Vector2(cx, 216),
		12,
		Color("#426c82")
	)

	draw_circle(
		Vector2(cx, 216),
		8,
		Color("#78d9e4")
	)

	draw_circle(
		Vector2(cx - 3, 212),
		3,
		Color("#d8f9ff")
	)

	# Left fin
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx - 23, 232),
			Vector2(cx - 45, 272),
			Vector2(cx - 23, 266)
		]),
		Color("#d86e70")
	)

	# Right fin
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx + 23, 232),
			Vector2(cx + 45, 272),
			Vector2(cx + 23, 266)
		]),
		Color("#d86e70")
	)

	# Engine
	draw_rect(
		Rect2(cx - 17, 266, 34, 11),
		Color("#506579")
	)

	# Engine fire
	if flame_strength > 0.01:

		var length: float = (
			22.0 + 42.0 * flame_strength
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 15, 277),
				Vector2(cx, 277 + length),
				Vector2(cx + 15, 277)
			]),
			Color("#ff973c")
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 8, 277),
				Vector2(cx, 277 + length * 0.72),
				Vector2(cx + 8, 277)
			]),
			Color("#ffe391")
		)


# ==========================================
# INTERFACE HELPERS
# ==========================================

func _panel(
	pos: Vector2,
	dimensions: Vector2
) -> Panel:

	var result := Panel.new()

	result.position = pos
	result.size = dimensions

	var style := StyleBoxFlat.new()

	style.bg_color = PANEL
	style.border_color = BORDER

	style.set_border_width_all(1)
	style.set_corner_radius_all(5)

	result.add_theme_stylebox_override(
		"panel",
		style
	)

	add_child(result)

	return result


func _label(
	value: String,
	pos: Vector2,
	dimensions: Vector2,
	font_size: int = 11,
	colour: Color = TEXT
) -> Label:

	var result := Label.new()

	result.text = value
	result.position = pos
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

	add_child(result)

	return result


func _button(
	value: String,
	pos: Vector2,
	dimensions: Vector2
) -> Button:

	var result := Button.new()

	result.text = value
	result.position = pos
	result.size = dimensions

	result.add_theme_font_size_override(
		"font_size",
		11
	)

	var normal := StyleBoxFlat.new()

	normal.bg_color = Color("#205875")
	normal.border_color = ACCENT

	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)

	result.add_theme_stylebox_override(
		"normal",
		normal
	)

	var hover := normal.duplicate() as StyleBoxFlat

	hover.bg_color = Color("#287b94")

	result.add_theme_stylebox_override(
		"hover",
		hover
	)

	var disabled := normal.duplicate() as StyleBoxFlat

	disabled.bg_color = Color("#293e4c")

	result.add_theme_stylebox_override(
		"disabled",
		disabled
	)

	add_child(result)

	return result


# ==========================================
# BUILD USER INTERFACE
# ==========================================

func _build_interface() -> void:

	_panel(
		Vector2(8, 8),
		Vector2(624, 42)
	)

	title_label = _label(
		"SPACE VAULT // FINAL LAUNCH",
		Vector2(21, 16),
		Vector2(390, 25),
		17,
		ACCENT
	)

	_panel(
		Vector2(324, 61),
		Vector2(308, 221)
	)

	_label(
		"PRE-FLIGHT CHECKLIST",
		Vector2(338, 75),
		Vector2(277, 23),
		14,
		ACCENT
	)

	assembly_label = _label(
		"",
		Vector2(339, 107),
		Vector2(278, 21)
	)

	power_label = _label(
		"",
		Vector2(339, 135),
		Vector2(278, 21)
	)

	launch_label = _label(
		"",
		Vector2(339, 163),
		Vector2(278, 21)
	)

	comms_label = _label(
		"",
		Vector2(339, 191),
		Vector2(278, 21)
	)

	status_label = _label(
		"",
		Vector2(339, 225),
		Vector2(277, 43),
		10,
		YELLOW
	)

	_panel(
		Vector2(8, 315),
		Vector2(624, 38)
	)

	matcha_label = _label(
		"MATCHA: Pre-flight systems standing by, sir.",
		Vector2(19, 322),
		Vector2(601, 27),
		10,
		TEXT
	)

	launch_button = _button(
		"INITIATE LAUNCH",
		Vector2(324, 288),
		Vector2(174, 25)
	)

	launch_button.pressed.connect(
		_start_launch
	)

	back_button = _button(
		"RECHECK",
		Vector2(508, 288),
		Vector2(124, 25)
	)

	back_button.pressed.connect(
		_on_recheck_pressed
	)

	progress_label = _label(
		"ROCKET STATUS: STANDBY",
		Vector2(70, 60),
		Vector2(240, 26),
		10,
		GREEN
	)


# ==========================================
# STATUS DISPLAY
# ==========================================

func _set_check_label(
	target: Label,
	title: String,
	passed: bool
) -> void:

	if passed:

		target.text = (
			"[PASS] " + title
		)

		target.add_theme_color_override(
			"font_color",
			GREEN
		)

	else:

		target.text = (
			"[FAIL] " + title
		)

		target.add_theme_color_override(
			"font_color",
			RED
		)


# ==========================================
# PREFLIGHT CHECKS
# ==========================================

func _refresh_checks() -> void:

	if launching:
		return

	var progress_ok: bool = (
		SpacecraftGameState.is_final_escape_unlocked()
	)

	var assembly_ok: bool = (
		SpacecraftGameState.is_ship_complete()
	)

	var power_result: Dictionary = (
		SpacecraftGameState.check_eclipse(35.0)
	)

	var launch_result: Dictionary = (
		SpacecraftGameState.check_launch(500.0)
	)

	var comms_result: Dictionary = (
		SpacecraftGameState.check_communications(
			20.0,
			6.0,
			15.0
		)
	)

	var power_ok: bool = (
		bool(power_result.get("valid", false))
		and bool(power_result.get("success", false))
	)

	var thrust_ok: bool = (
		bool(launch_result.get("valid", false))
		and bool(launch_result.get("success", false))
	)

	var comms_ok: bool = (
		bool(comms_result.get("valid", false))
		and bool(comms_result.get("success", false))
	)

	checks = {
		"scientists": progress_ok,
		"assembly": assembly_ok,
		"power": power_ok,
		"launch": thrust_ok,
		"communications": comms_ok
	}

	launch_ready = (
		progress_ok
		and assembly_ok
		and power_ok
		and thrust_ok
		and comms_ok
	)

	_set_check_label(
		assembly_label,
		"Spacecraft assembly",
		assembly_ok
	)

	_set_check_label(
		power_label,
		"Battery and eclipse",
		power_ok
	)

	_set_check_label(
		launch_label,
		"Thrust and mass",
		thrust_ok
	)

	_set_check_label(
		comms_label,
		"Science communications",
		comms_ok
	)

	launch_button.disabled = not launch_ready

	if not progress_ok:

		status_label.text = (
			"LOCKED: Defeat all four Scientists."
		)

		_matcha(
			"Four opponents stand between us and orbit, sir."
		)

	elif not assembly_ok:

		status_label.text = (
			"INCOMPLETE: Install all six systems."
		)

		_matcha(
			"A rocket with missing parts is rather ambitious, sir."
		)

	elif not power_ok:

		status_label.text = (
			"NOT READY: Power endurance failed."
		)

		_matcha(
			"Our batteries need attention, sir."
		)

	elif not thrust_ok:

		status_label.text = (
			"NOT READY: Launch performance failed."
		)

		_matcha(
			"Insufficient launch performance, sir."
		)

	elif not comms_ok:

		status_label.text = (
			"NOT READY: Communications failed."
		)

		_matcha(
			"We must transmit our findings, sir."
		)

	else:

		status_label.text = (
			"ALL SYSTEMS GO // LAUNCH AUTHORISED"
		)

		status_label.add_theme_color_override(
			"font_color",
			GREEN
		)

		_matcha(
			"All systems nominal, sir. Earth has been lovely."
		)


# ==========================================
# MATCHA DIALOGUE
# ==========================================

func _matcha(message: String) -> void:

	if is_instance_valid(matcha_label):

		matcha_label.text = (
			"MATCHA: " + message
		)


# ==========================================
# LAUNCH SEQUENCE
# ==========================================

func _start_launch() -> void:

	if launching or mission_complete:
		return

	# Recheck immediately before launch.
	_refresh_checks()

	if not launch_ready:

		_matcha(
			"Launch denied, sir. Safety first."
		)

		return

	launching = true

	launch_button.disabled = true
	back_button.disabled = true

	progress_label.text = (
		"ROCKET STATUS: IGNITION"
	)

	_matcha(
		"Ignition sequence initiated. "
		+ "A fine day to leave the planet, sir."
	)

	# Engine ignition
	var ignition := create_tween()

	ignition.tween_property(
		self,
		"flame_strength",
		1.0,
		1.3
	)

	await ignition.finished

	_matcha(
		"Engine thrust stable. "
		+ "Beginning ascent, sir."
	)

	progress_label.text = (
		"ROCKET STATUS: LIFTOFF"
	)

	# Main rocket ascent
	var ascent := create_tween()

	ascent.set_trans(
		Tween.TRANS_SINE
	)

	ascent.set_ease(
		Tween.EASE_IN
	)

	ascent.tween_property(
		self,
		"launch_height",
		185.0,
		2.0
	)

	await ascent.finished

	_matcha(
		"Ascending rapidly. "
		+ "The Scientists are now rather far below us."
	)

	progress_label.text = (
		"ROCKET STATUS: ASCENDING"
	)

	var climb := create_tween()

	climb.tween_property(
		self,
		"launch_height",
		510.0,
		2.3
	)

	await climb.finished

	_complete_launch()


# ==========================================
# SUCCESSFUL ESCAPE
# ==========================================

func _complete_launch() -> void:

	launching = false
	mission_complete = true

	flame_strength = 0.0

	progress_label.text = (
		"MISSION STATUS: ESCAPE SUCCESSFUL"
	)

	title_label.text = (
		"SPACE VAULT // MISSION COMPLETE"
	)

	status_label.text = (
		"JOE PENG HAS ESCAPED EARTH!"
	)

	status_label.add_theme_color_override(
		"font_color",
		GREEN
	)

	_matcha(
		"Earth escaped, sir. "
		+ "I shall miss absolutely none of the security procedures."
	)

	launch_button.text = "MISSION COMPLETE"
	launch_button.disabled = true

	back_button.text = "REVIEW"
	back_button.disabled = false

	launch_completed.emit()


# ==========================================
# RECHECK / REVIEW
# ==========================================

func _on_recheck_pressed() -> void:

	if launching:
		return

	if mission_complete:

		mission_complete = false

		launch_height = 0.0
		flame_strength = 0.0

		title_label.text = (
			"SPACE VAULT // FINAL LAUNCH"
		)

		progress_label.text = (
			"ROCKET STATUS: STANDBY"
		)

		launch_button.text = (
			"INITIATE LAUNCH"
		)

	_refresh_checks()
