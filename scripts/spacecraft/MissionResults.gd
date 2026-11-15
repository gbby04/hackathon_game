
extends Control

# ============================================================
# SPACE VAULT - MISSION RESULTS
# Godot 4.7
#
# REDESIGNED CINEMATIC ENDING
#
# Preserved:
# - Mission engineering calculations
# - NASA-linked MissionSimulation
# - Spacecraft configuration results
# - Scientist progression requirements
# - Matcha engineering assessment
# - Mission debrief screen
# - VIEW ENDING button
# - Return to mission debrief
#
# Improved:
# - Cleaner cinematic ending composition
# - Large animated Joe Peng
# - Smaller atmospheric Earth
# - Properly aligned title and dialogue
# - No overlapping portrait or text
# - Dedicated Matcha message area
# - Compact return button
#
# FILE:
# res://scripts/spacecraft/MissionResults.gd
# ============================================================


# ============================================================
# PATHS
# ============================================================

const PREFLIGHT_SCENE: String = (
	"res://scenes/spacecraft/EscapeLaunch.tscn"
)

const JOE_IDLE_PATH: String = (
	"res://assets/story/joe_idle_side-Sheet.png"
)

const JOE_STATIC_PATH: String = (
	"res://assets/battles/characters/joe_peng/joe_peng.png"
)


# ============================================================
# SCREEN
# ============================================================

const SCREEN_SIZE: Vector2 = Vector2(640, 360)


# ============================================================
# COLOURS
# ============================================================

const BG: Color = Color("#091524")
const HEADER: Color = Color("#10243a")
const CARD: Color = Color("#162940")
const BORDER: Color = Color("#29445c")

const WHITE: Color = Color("#eaf6ff")
const MUTED: Color = Color("#a5b9cc")
const ACCENT: Color = Color("#50d4e8")

const GOOD: Color = Color("#7deda4")
const BAD: Color = Color("#ff8a8a")
const WARNING: Color = Color("#ffca70")


# ============================================================
# MISSION PARAMETERS
# ============================================================

# Existing simplified gameplay scenarios.
# Not literal NASA mission requirements.

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


# ============================================================
# SPACE BACKGROUND FOR ENDING
# ============================================================

class CinematicSpace:
	extends Control

	const SPACE_BG: Color = Color("#030916")
	const SPACE_DEEP: Color = Color("#071326")
	const EARTH_OCEAN: Color = Color("#397fc4")
	const EARTH_LAND: Color = Color("#65af80")
	const EARTH_CLOUD: Color = Color("#d4edff")

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()


	func _draw() -> void:
		# Base background
		draw_rect(
			Rect2(0, 0, 640, 360),
			SPACE_BG
		)

		# Subtle horizontal atmosphere-like tint
		draw_rect(
			Rect2(0, 0, 640, 145),
			SPACE_DEEP
		)

		draw_rect(
			Rect2(0, 145, 640, 215),
			Color("#030916")
		)

		_draw_stars()
		_draw_earth()
		_draw_horizon()


	func _draw_stars() -> void:
		var stars: Array[Vector2] = [
			Vector2(22, 23),
			Vector2(61, 83),
			Vector2(105, 17),
			Vector2(151, 33),
			Vector2(205, 13),
			Vector2(279, 32),
			Vector2(344, 19),
			Vector2(401, 66),
			Vector2(450, 24),
			Vector2(591, 28),
			Vector2(618, 81),
			Vector2(31, 119),
			Vector2(86, 149),
			Vector2(219, 130),
			Vector2(286, 145),
			Vector2(354, 116),
			Vector2(422, 149),
			Vector2(601, 156),
			Vector2(57, 220),
			Vector2(334, 273),
			Vector2(611, 254)
		]

		for i in range(stars.size()):
			var opacity: float = 0.45

			if i % 3 == 0:
				opacity = 0.85

			var radius: float = 0.8

			if i % 7 == 0:
				radius = 1.3

			draw_circle(
				stars[i],
				radius,
				Color(0.85, 0.93, 1.0, opacity)
			)


	func _draw_earth() -> void:
		# Earth is deliberately smaller than
		# the title and main character.
		var centre: Vector2 = Vector2(520, 94)

		# Atmospheric glow
		draw_circle(
			centre,
			76.0,
			Color("#3278b3", 0.07)
		)

		draw_circle(
			centre,
			68.0,
			Color("#438bc7", 0.12)
		)

		draw_circle(
			centre,
			59.0,
			Color("#5c9bd7", 0.18)
		)

		# Planet surface
		draw_circle(
			centre,
			56.0,
			EARTH_OCEAN
		)

		# Stylised land, kept within sphere
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(493, 55),
				Vector2(513, 49),
				Vector2(528, 60),
				Vector2(525, 75),
				Vector2(508, 85),
				Vector2(494, 77),
				Vector2(486, 66)
			]),
			EARTH_LAND
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(523, 94),
				Vector2(544, 85),
				Vector2(560, 103),
				Vector2(554, 121),
				Vector2(539, 133),
				Vector2(525, 118)
			]),
			EARTH_LAND
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(482, 106),
				Vector2(498, 99),
				Vector2(508, 112),
				Vector2(503, 130),
				Vector2(490, 135),
				Vector2(482, 121)
			]),
			EARTH_LAND
		)

		# Clouds
		draw_line(
			Vector2(471, 91),
			Vector2(501, 91),
			EARTH_CLOUD,
			2.0
		)

		draw_line(
			Vector2(520, 78),
			Vector2(550, 78),
			EARTH_CLOUD,
			2.0
		)

		draw_line(
			Vector2(509, 139),
			Vector2(535, 139),
			EARTH_CLOUD,
			2.0
		)

		# Dark shading over right hemisphere
		draw_arc(
			centre,
			51.0,
			-1.1,
			1.1,
			30,
			Color(0.02, 0.09, 0.18, 0.5),
			8.0
		)

		# Thin atmospheric edge
		draw_arc(
			centre,
			57.0,
			0.0,
			TAU,
			64,
			Color("#88cbf0", 0.8),
			1.5
		)


	func _draw_horizon() -> void:
		# Subtle visual separation underneath
		# the title and character.
		draw_line(
			Vector2(35, 152),
			Vector2(605, 152),
			Color("#244052", 0.65),
			1.0
		)

		# Floor shadow behind Joe
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(56, 286),
				Vector2(206, 286),
				Vector2(219, 297),
				Vector2(42, 297)
			]),
			Color("#112337", 0.45)
		)


# ============================================================
# GAME STATE
# ============================================================

var mission_passed: bool = false

var stats: Dictionary = {}
var results: Dictionary = {}

var ending_open: bool = false
var ending_transition: bool = false


# ============================================================
# MAIN UI
# ============================================================

var status_label: Label
var assembly_label: Label
var assembly_status: Label
var matcha_label: Label

var result_cards: Dictionary = {}

var back_button: Button
var recheck_button: Button
var ending_button: Button


# ============================================================
# ENDING UI
# ============================================================

var ending_overlay: Control
var ending_joe: AnimatedSprite2D
var ending_static_joe: Sprite2D


# ============================================================
# READY
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
	_build_ending()

	_refresh_results()


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
	style.set_corner_radius_all(5)

	return style


func _panel(
	parent_node: Node,
	at: Vector2,
	dimensions: Vector2,
	background_colour: Color,
	border_colour: Color = BORDER
) -> Panel:
	var panel: Panel = Panel.new()

	panel.position = at
	panel.size = dimensions

	panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	panel.add_theme_stylebox_override(
		"panel",
		_style(background_colour, border_colour)
	)

	parent_node.add_child(panel)

	return panel


func _label(
	parent_node: Node,
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

	parent_node.add_child(result)

	return result


func _button(
	parent_node: Node,
	value: String,
	at: Vector2,
	dimensions: Vector2,
	primary: bool = false
) -> Button:
	var button: Button = Button.new()

	button.text = value
	button.position = at
	button.size = dimensions

	button.focus_mode = Control.FOCUS_NONE

	button.add_theme_font_size_override(
		"font_size",
		10
	)

	var normal_colour: Color = CARD

	if primary:
		normal_colour = Color("#176f91")

	button.add_theme_stylebox_override(
		"normal",
		_style(normal_colour)
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
		_style(Color("#233649"))
	)

	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	for colour_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color"
	]:
		button.add_theme_color_override(
			colour_name,
			WHITE
		)

	button.add_theme_color_override(
		"font_disabled_color",
		MUTED
	)

	parent_node.add_child(button)

	return button


# ============================================================
# BUILD MISSION DEBRIEF
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
		self,
		Vector2(8, 8),
		Vector2(624, 49),
		HEADER
	)

	_label(
		self,
		"MISSION DEBRIEF",
		Vector2(19, 14),
		Vector2(310, 24),
		19,
		ACCENT
	)

	_label(
		self,
		"SPACE VAULT / FINAL ENGINEERING RESULTS",
		Vector2(20, 39),
		Vector2(335, 13),
		8,
		MUTED
	)

	status_label = _label(
		self,
		"",
		Vector2(390, 24),
		Vector2(226, 20),
		11,
		WARNING
	)

	status_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	# Spacecraft summary
	_panel(
		self,
		Vector2(8, 65),
		Vector2(624, 66),
		CARD
	)

	_label(
		self,
		"SPACECRAFT CONFIGURATION",
		Vector2(19, 73),
		Vector2(320, 17),
		11,
		ACCENT
	)

	assembly_label = _label(
		self,
		"",
		Vector2(19, 94),
		Vector2(385, 27),
		12,
		WHITE
	)

	assembly_status = _label(
		self,
		"",
		Vector2(427, 92),
		Vector2(190, 25),
		13,
		WARNING
	)

	assembly_status.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	# Engineering checks
	_create_result_card(
		"power",
		"01",
		"ECLIPSE ENDURANCE",
		Vector2(8, 139)
	)

	_create_result_card(
		"launch",
		"02",
		"LAUNCH PERFORMANCE",
		Vector2(220, 139)
	)

	_create_result_card(
		"communications",
		"03",
		"SCIENCE DATA RETURN",
		Vector2(432, 139)
	)

	_label(
		self,
		"NASA Earth gravity reference. Mission thresholds and components use simplified gameplay parameters.",
		Vector2(14, 248),
		Vector2(612, 13),
		8,
		MUTED
	)

	# Matcha assessment
	_panel(
		self,
		Vector2(8, 264),
		Vector2(624, 49),
		HEADER
	)

	_label(
		self,
		"MATCHA",
		Vector2(19, 273),
		Vector2(64, 17),
		11,
		ACCENT
	)

	matcha_label = _label(
		self,
		"",
		Vector2(91, 273),
		Vector2(525, 33),
		10,
		WHITE
	)

	back_button = _button(
		self,
		"PREFLIGHT",
		Vector2(8, 322),
		Vector2(135, 30)
	)

	recheck_button = _button(
		self,
		"RECHECK",
		Vector2(151, 322),
		Vector2(135, 30)
	)

	ending_button = _button(
		self,
		"VIEW ENDING",
		Vector2(294, 322),
		Vector2(338, 30),
		true
	)

	back_button.pressed.connect(
		_back_to_preflight
	)

	recheck_button.pressed.connect(
		_refresh_results
	)

	ending_button.pressed.connect(
		_open_ending
	)


# ============================================================
# RESULT CARDS
# ============================================================

func _create_result_card(
	id: String,
	number: String,
	title_text: String,
	at: Vector2
) -> void:
	_panel(
		self,
		at,
		Vector2(200, 103),
		CARD
	)

	_label(
		self,
		number,
		at + Vector2(10, 9),
		Vector2(26, 18),
		13,
		ACCENT
	)

	_label(
		self,
		title_text,
		at + Vector2(37, 10),
		Vector2(156, 18),
		10,
		WHITE
	)

	var state: Label = _label(
		self,
		"",
		at + Vector2(11, 35),
		Vector2(180, 23),
		13,
		WARNING
	)

	var detail: Label = _label(
		self,
		"",
		at + Vector2(11, 64),
		Vector2(179, 31),
		9,
		MUTED
	)

	result_cards[id] = {
		"status": state,
		"detail": detail
	}


func _set_result_card(
	id: String,
	passed: bool,
	detail_text: String
) -> void:
	var entry: Dictionary = result_cards[id]

	var state_label: Label = entry["status"]
	var detail_label: Label = entry["detail"]

	state_label.text = (
		"PASS"
		if passed
		else "FAIL"
	)

	state_label.add_theme_color_override(
		"font_color",
		GOOD if passed else BAD
	)

	detail_label.text = detail_text


# ============================================================
# ENGINEERING CHECKS
# ============================================================

func _has_all_components() -> bool:
	var equipped: Dictionary = (
		SpacecraftGameState.get_equipped_components()
	)

	for category in REQUIRED_CATEGORIES:
		if str(
			equipped.get(category, "")
		).is_empty():
			return false

	return true


func _refresh_results() -> void:
	stats = SpacecraftGameState.get_ship_stats()

	var simulator: MissionSimulation = (
		SpacecraftGameState.simulator
	)

	var eclipse: Dictionary = (
		simulator.check_eclipse(
			stats,
			ECLIPSE_MINUTES
		)
	)

	var launch: Dictionary = (
		simulator.check_launch(
			stats,
			MASS_LIMIT_KG
		)
	)

	var communications: Dictionary = (
		simulator.check_communications(
			stats,
			OBSERVATION_MINUTES,
			CONTACT_MINUTES,
			REQUIRED_DATA_MB
		)
	)

	var assembly_ok: bool = _has_all_components()

	var power_ok: bool = (
		bool(eclipse.get("valid", false))
		and bool(eclipse.get("success", false))
	)

	var launch_ok: bool = (
		bool(launch.get("valid", false))
		and bool(launch.get("success", false))
	)

	var comms_ok: bool = (
		bool(communications.get("valid", false))
		and bool(communications.get("success", false))
	)

	var scientists_ok: bool = (
		SpacecraftGameState.is_final_escape_unlocked()
	)

	mission_passed = (
		assembly_ok
		and scientists_ok
		and power_ok
		and launch_ok
		and comms_ok
	)

	results = {
		"eclipse": eclipse,
		"launch": launch,
		"communications": communications
	}

	_update_summary(
		assembly_ok,
		scientists_ok
	)

	_update_power_card(
		eclipse,
		power_ok
	)

	_update_launch_card(
		launch,
		launch_ok
	)

	_update_communications_card(
		communications,
		comms_ok
	)

	_update_matcha(
		assembly_ok,
		scientists_ok,
		power_ok,
		launch_ok,
		comms_ok
	)

	ending_button.disabled = not mission_passed


# ============================================================
# MISSION SUMMARY
# ============================================================

func _update_summary(
	assembly_ok: bool,
	scientists_ok: bool
) -> void:
	var count: int = int(
		stats.get("equipped_count", 0)
	)

	var mass: float = float(
		stats.get("mass_kg", 0.0)
	)

	var budget: float = float(
		stats.get("budget_remaining", 0.0)
	)

	assembly_label.text = (
		"%d/6 systems   |   %.1f kg   |   %.0f credits left"
	) % [
		count,
		mass,
		budget
	]

	if assembly_ok and scientists_ok:
		assembly_status.text = "ASSEMBLY VERIFIED"

		assembly_status.add_theme_color_override(
			"font_color",
			GOOD
		)
	else:
		assembly_status.text = "INCOMPLETE"

		assembly_status.add_theme_color_override(
			"font_color",
			WARNING
		)


func _update_power_card(
	result: Dictionary,
	passed: bool
) -> void:
	var battery: float = float(
		stats.get("battery_wh", 0.0)
	)

	var required: float = float(
		result.get("energy_required_wh", 0.0)
	)

	var remaining: float = float(
		result.get("battery_remaining_wh", 0.0)
	)

	_set_result_card(
		"power",
		passed,
		(
			"Battery %.1f Wh\n"
			+ "Used %.1f / Left %.1f Wh"
		) % [
			battery,
			required,
			remaining
		]
	)


func _update_launch_card(
	result: Dictionary,
	passed: bool
) -> void:
	var mass: float = float(
		stats.get("mass_kg", 0.0)
	)

	var thrust: float = float(
		stats.get("thrust_kn", 0.0)
	)

	var ratio: float = float(
		result.get("thrust_to_weight", 0.0)
	)

	_set_result_card(
		"launch",
		passed,
		(
			"Mass %.1f kg / Thrust %.1f kN\n"
			+ "Thrust-to-weight %.2f"
		) % [
			mass,
			thrust,
			ratio
		]
	)


func _update_communications_card(
	result: Dictionary,
	passed: bool
) -> void:
	var generated: float = float(
		result.get("generated_data_mb", 0.0)
	)

	var transmitted: float = float(
		result.get("transmitted_data_mb", 0.0)
	)

	_set_result_card(
		"communications",
		passed,
		(
			"Generated %.1f MB\n"
			+ "Delivered %.1f / %.1f MB"
		) % [
			generated,
			transmitted,
			REQUIRED_DATA_MB
		]
	)


# ============================================================
# MATCHA ASSESSMENT
# ============================================================

func _update_matcha(
	assembly_ok: bool,
	scientists_ok: bool,
	power_ok: bool,
	launch_ok: bool,
	comms_ok: bool
) -> void:
	if mission_passed:
		status_label.text = "SIMULATION PASSED"

		status_label.add_theme_color_override(
			"font_color",
			GOOD
		)

		matcha_label.text = (
			"Four Scientists defeated, sir. "
			+ "All baseline mission systems passed."
		)

		return

	status_label.text = "REVIEW REQUIRED"

	status_label.add_theme_color_override(
		"font_color",
		BAD
	)

	if not scientists_ok:
		matcha_label.text = (
			"Defeat all four Scientists "
			+ "before attempting final escape."
		)

	elif not assembly_ok:
		matcha_label.text = (
			"Six component categories "
			+ "are required for launch."
		)

	elif not power_ok:
		matcha_label.text = (
			"Power endurance is insufficient. "
			+ "Review the battery."
		)

	elif not launch_ok:
		matcha_label.text = (
			"Launch performance failed. "
			+ "Check thrust, mass and budget."
		)

	elif not comms_ok:
		matcha_label.text = (
			"Data transmission is insufficient. "
			+ "Review communications."
		)


# ============================================================
# REDESIGNED CINEMATIC ENDING
# ============================================================

func _build_ending() -> void:
	ending_overlay = Control.new()

	ending_overlay.name = "EndingOverlay"

	add_child(ending_overlay)

	ending_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	ending_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	# Full-screen cinematic background
	var backdrop: CinematicSpace = CinematicSpace.new()

	backdrop.name = "CinematicBackground"
	backdrop.size = SCREEN_SIZE

	ending_overlay.add_child(backdrop)

	# -----------------------------------------
	# CINEMATIC TITLE
	# -----------------------------------------

	_label(
		ending_overlay,
		"MISSION ACCOMPLISHED",
		Vector2(38, 28),
		Vector2(330, 17),
		10,
		GOOD
	)

	_label(
		ending_overlay,
		"SPACE VAULT",
		Vector2(36, 53),
		Vector2(385, 42),
		31,
		ACCENT
	)

	_label(
		ending_overlay,
		"ESCAPE FROM EARTH",
		Vector2(39, 103),
		Vector2(300, 24),
		15,
		WHITE
	)

	# Short decorative line under title
	var accent_line: ColorRect = ColorRect.new()

	accent_line.position = Vector2(39, 137)
	accent_line.size = Vector2(220, 2)
	accent_line.color = ACCENT

	accent_line.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	ending_overlay.add_child(accent_line)

	# -----------------------------------------
	# JOE PENG - FOREGROUND
	# -----------------------------------------

	_create_ending_joe()

	# -----------------------------------------
	# JOE'S CLOSING DIALOGUE
	# -----------------------------------------

	_panel(
		ending_overlay,
		Vector2(239, 169),
		Vector2(362, 101),
		Color("#0c1728"),
		Color("#41667c")
	)

	_label(
		ending_overlay,
		"JOE PENG",
		Vector2(257, 180),
		Vector2(298, 19),
		12,
		ACCENT
	)

	_label(
		ending_overlay,
		"Finally...",
		Vector2(257, 205),
		Vector2(310, 23),
		18,
		WHITE
	)

	_label(
		ending_overlay,
		"I can go home.",
		Vector2(257, 233),
		Vector2(312, 25),
		18,
		WHITE
	)

	# -----------------------------------------
	# MATCHA - FINAL MESSAGE
	# -----------------------------------------

	_panel(
		ending_overlay,
		Vector2(37, 292),
		Vector2(566, 30),
		Color("#101f32")
	)

	_label(
		ending_overlay,
		"MATCHA",
		Vector2(48, 300),
		Vector2(66, 16),
		10,
		ACCENT
	)

	_label(
		ending_overlay,
		"Welcome home, sir. Mission accomplished.",
		Vector2(118, 299),
		Vector2(466, 18),
		11,
		WHITE
	)

	# -----------------------------------------
	# FOOTER
	# -----------------------------------------

	_label(
		ending_overlay,
		"THE END",
		Vector2(38, 332),
		Vector2(120, 18),
		11,
		MUTED
	)

	var return_button: Button = _button(
		ending_overlay,
		"RETURN TO DEBRIEF",
		Vector2(399, 327),
		Vector2(204, 27),
		true
	)

	return_button.pressed.connect(
		_close_ending
	)

	ending_overlay.hide()


# ============================================================
# JOE PENG - ANIMATED PORTRAIT
# ============================================================

func _create_ending_joe() -> void:
	ending_joe = AnimatedSprite2D.new()

	ending_joe.name = "EndingJoe"

	# Position accounts for the 64x64 frame
	# and the enlarged pixel-art sprite.
	#
	# Joe is positioned in the left foreground,
	# entirely above the Matcha panel.
	ending_joe.position = Vector2(133, 211)
	ending_joe.scale = Vector2(2.55, 2.55)

	ending_joe.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	ending_overlay.add_child(ending_joe)

	if _load_joe_animation():
		return

	# Static fallback
	ending_joe.hide()

	if not ResourceLoader.exists(JOE_STATIC_PATH):
		push_warning(
			"Joe sprite missing: "
			+ JOE_IDLE_PATH
		)
		return

	var texture: Texture2D = (
		load(JOE_STATIC_PATH) as Texture2D
	)

	if texture == null:
		return

	ending_static_joe = Sprite2D.new()

	ending_static_joe.texture = texture
	ending_static_joe.position = Vector2(133, 211)
	ending_static_joe.scale = Vector2(2.55, 2.55)

	ending_static_joe.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	ending_overlay.add_child(ending_static_joe)


func _load_joe_animation() -> bool:
	if not ResourceLoader.exists(JOE_IDLE_PATH):
		return false

	var texture: Texture2D = (
		load(JOE_IDLE_PATH) as Texture2D
	)

	if texture == null:
		return false

	# Four horizontal frames, 64x64 each.
	if (
		texture.get_width() < 256
		or texture.get_height() < 64
	):
		push_warning(
			"Joe idle sprite sheet must contain "
			+ "four horizontal 64x64 frames."
		)
		return false

	var frames: SpriteFrames = SpriteFrames.new()

	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("idle")

	frames.set_animation_speed(
		"idle",
		4.0
	)

	frames.set_animation_loop(
		"idle",
		true
	)

	for i in range(4):
		var atlas: AtlasTexture = AtlasTexture.new()

		atlas.atlas = texture

		atlas.region = Rect2(
			float(i * 64),
			0.0,
			64.0,
			64.0
		)

		frames.add_frame(
			"idle",
			atlas
		)

	ending_joe.sprite_frames = frames

	ending_joe.play("idle")
	ending_joe.show()

	return true


# ============================================================
# OPEN ENDING
# ============================================================

func _open_ending() -> void:
	if not mission_passed:
		return

	if ending_open or ending_transition:
		return

	ending_open = true
	ending_transition = true

	ending_overlay.show()
	ending_overlay.move_to_front()

	ending_overlay.modulate.a = 0.0

	var fade: Tween = create_tween()

	fade.tween_property(
		ending_overlay,
		"modulate:a",
		1.0,
		0.7
	)

	await fade.finished

	ending_transition = false


# ============================================================
# CLOSE ENDING
# ============================================================

func _close_ending() -> void:
	if ending_transition:
		return

	if not ending_open:
		return

	ending_transition = true

	var fade: Tween = create_tween()

	fade.tween_property(
		ending_overlay,
		"modulate:a",
		0.0,
		0.45
	)

	await fade.finished

	ending_overlay.hide()

	ending_open = false
	ending_transition = false


# ============================================================
# BACK TO PREFLIGHT
# ============================================================

func _back_to_preflight() -> void:
	if ending_open:
		return

	if not ResourceLoader.exists(PREFLIGHT_SCENE):
		push_error(
			"Preflight scene missing: "
			+ PREFLIGHT_SCENE
		)
		return

	get_tree().change_scene_to_file(
		PREFLIGHT_SCENE
	)
