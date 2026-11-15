extends Control

# ==========================================================
# SPACE VAULT - IMPROVED GAME OVER SCREEN
# Godot 4.7
#
# - Better visual hierarchy
# - Centered cinematic failure card
# - Retry button
# - Scientist-specific failure message
# - No extra assets needed
# - Resets only when RETRY is pressed
# ==========================================================

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const OUTSIDE_SCENE: String = "res://scenes/story/OutsideLab.tscn"

const SCIENTIST_NAMES: Dictionary = {
	"niq": "DR. NIQ",
	"gabby": "DR. GABBY",
	"ahmed": "DR. AHMED",
	"celine": "DR. CELINE"
}

const FAILURE_REASONS: Dictionary = {
	"niq": "Your spacecraft failed the eclipse endurance challenge.",
	"gabby": "Your spacecraft failed the launch performance challenge.",
	"ahmed": "Your spacecraft failed the communications challenge.",
	"celine": "Your spacecraft failed the final engineering examination."
}

# ----------------------------------------------------------
# COLOURS
# ----------------------------------------------------------

const BG_TOP: Color = Color("#040812")
const BG_BOTTOM: Color = Color("#091525")

const PANEL_BG: Color = Color("#0f1a2b")
const PANEL_BORDER: Color = Color("#2a4660")
const PANEL_INNER: Color = Color("#142338")

const TITLE_RED: Color = Color("#ff6f7d")
const SUBTEXT: Color = Color("#a9bbca")
const WHITE: Color = Color("#eef5fb")
const ACCENT: Color = Color("#6ed7f2")
const WARNING: Color = Color("#ffbe6b")
const DIM: Color = Color("#6d8091")

# ----------------------------------------------------------
# STATE
# ----------------------------------------------------------

var failed_scientist: String = "niq"
var transitioning: bool = false
var pulse_time: float = 0.0

# ----------------------------------------------------------
# NODES
# ----------------------------------------------------------

var title_label: Label
var retry_button: Button
var fade_overlay: ColorRect
var warning_badge: Panel

# ----------------------------------------------------------
# READY
# ----------------------------------------------------------

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if get_tree().has_meta("space_vault_failed_scientist"):
		failed_scientist = str(get_tree().get_meta("space_vault_failed_scientist"))

	if not SCIENTIST_NAMES.has(failed_scientist):
		failed_scientist = "niq"

	_build_screen()
	_fade_in()

# ----------------------------------------------------------
# PROCESS
# ----------------------------------------------------------

func _process(delta: float) -> void:
	pulse_time += delta

	if is_instance_valid(title_label):
		var pulse := 0.92 + sin(pulse_time * 2.2) * 0.08
		title_label.modulate = Color(1.0, pulse, pulse, 1.0)

	if is_instance_valid(warning_badge):
		warning_badge.modulate = Color(1, 1, 1, 0.94 + sin(pulse_time * 2.6) * 0.06)

# ----------------------------------------------------------
# INPUT
# ----------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if transitioning:
		return

	if event.is_action_pressed("ui_accept"):
		_retry_mission()
		get_viewport().set_input_as_handled()

# ----------------------------------------------------------
# HELPERS
# ----------------------------------------------------------

func _make_label(
	parent_node: Node,
	value: String,
	at: Vector2,
	dimensions: Vector2,
	font_size: int,
	colour: Color,
	align: int = HORIZONTAL_ALIGNMENT_CENTER
) -> Label:
	var result := Label.new()
	result.text = value
	result.position = at
	result.size = dimensions
	result.horizontal_alignment = align
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", colour)
	parent_node.add_child(result)
	return result

func _make_panel_style(
	bg: Color,
	border: Color,
	border_width: int = 1,
	radius: int = 8
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style

# ----------------------------------------------------------
# BUILD SCREEN
# ----------------------------------------------------------

func _build_screen() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = BG_TOP
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var lower_tint := ColorRect.new()
	lower_tint.position = Vector2(0, 180)
	lower_tint.size = Vector2(640, 180)
	lower_tint.color = BG_BOTTOM
	lower_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lower_tint)

	# Decorative glow circles
	_add_glow(Vector2(120, 90), 140, Color(0.45, 0.10, 0.14, 0.08))
	_add_glow(Vector2(530, 285), 110, Color(0.12, 0.35, 0.45, 0.06))

	# Main failure card shadow
	var shadow := Panel.new()
	shadow.position = Vector2(71, 54)
	shadow.size = Vector2(500, 252)
	shadow.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0, 0, 0, 0.28), Color(0, 0, 0, 0), 0, 10)
	)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shadow)

	# Main card
	var card := Panel.new()
	card.position = Vector2(66, 48)
	card.size = Vector2(500, 252)
	card.add_theme_stylebox_override(
		"panel",
		_make_panel_style(PANEL_BG, PANEL_BORDER, 1, 10)
	)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)

	# Top header strip
	var header_strip := Panel.new()
	header_strip.position = Vector2(66, 48)
	header_strip.size = Vector2(500, 42)
	header_strip.add_theme_stylebox_override(
		"panel",
		_make_panel_style(PANEL_INNER, Color("#365671"), 1, 10)
	)
	header_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header_strip)

	var bottom_cover := ColorRect.new()
	bottom_cover.position = Vector2(66, 80)
	bottom_cover.size = Vector2(500, 10)
	bottom_cover.color = PANEL_INNER
	bottom_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_cover)

	_make_label(
		self,
		"SPACE VAULT // SIMULATION TERMINATED",
		Vector2(84, 56),
		Vector2(464, 22),
		10,
		SUBTEXT
	)

	# Warning badge
	warning_badge = Panel.new()
	warning_badge.position = Vector2(266, 98)
	warning_badge.size = Vector2(100, 28)
	warning_badge.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color("#32171d"), Color("#924452"), 1, 14)
	)
	warning_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(warning_badge)

	_make_label(
		self,
		"WARNING",
		Vector2(276, 101),
		Vector2(80, 20),
		10,
		WARNING
	)

	# Main title
	title_label = _make_label(
		self,
		"GAME OVER",
		Vector2(125, 128),
		Vector2(382, 50),
		35,
		TITLE_RED
	)

	_make_label(
		self,
		"ESCAPE ATTEMPT FAILED",
		Vector2(145, 170),
		Vector2(342, 22),
		13,
		SUBTEXT
	)

	_make_label(
		self,
		"DEFEATED BY " + str(SCIENTIST_NAMES[failed_scientist]),
		Vector2(133, 198),
		Vector2(366, 22),
		12,
		ACCENT
	)

	# Reason box
	var info_box := Panel.new()
	info_box.position = Vector2(105, 227)
	info_box.size = Vector2(422, 46)
	info_box.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color("#101f31"), Color("#243d55"), 1, 6)
	)
	info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(info_box)

	_make_label(
		self,
		str(FAILURE_REASONS[failed_scientist]),
		Vector2(118, 234),
		Vector2(396, 30),
		11,
		WHITE
	)

	# Retry button
	retry_button = Button.new()
	retry_button.text = "RETRY"
	retry_button.position = Vector2(218, 289)
	retry_button.size = Vector2(196, 40)
	retry_button.focus_mode = Control.FOCUS_NONE
	retry_button.add_theme_font_size_override("font_size", 15)
	retry_button.add_theme_color_override("font_color", WHITE)
	retry_button.add_theme_color_override("font_hover_color", WHITE)
	retry_button.add_theme_color_override("font_pressed_color", WHITE)
	retry_button.add_theme_stylebox_override(
		"normal",
		_make_button_style(Color("#1a5873"), Color("#74d8ef"))
	)
	retry_button.add_theme_stylebox_override(
		"hover",
		_make_button_style(Color("#23779a"), Color("#96e6f6"))
	)
	retry_button.add_theme_stylebox_override(
		"pressed",
		_make_button_style(Color("#15475e"), Color("#74d8ef"))
	)
	retry_button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)
	retry_button.pressed.connect(_retry_mission)
	add_child(retry_button)

	# Footer hint
	_make_label(
		self,
		"Press Enter or click RETRY to attempt the mission again.",
		Vector2(106, 333),
		Vector2(428, 16),
		9,
		DIM
	)

	# Fade overlay
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 1.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fade_overlay)
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _add_glow(position_value: Vector2, radius: int, colour: Color) -> void:
	var glow := ColorRect.new()
	glow.position = position_value - Vector2(radius / 2.0, radius / 2.0)
	glow.size = Vector2(radius, radius)
	glow.color = colour
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)

# ----------------------------------------------------------
# FADE IN
# ----------------------------------------------------------

func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.55)
	await tween.finished
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ----------------------------------------------------------
# RETRY
# ----------------------------------------------------------

func _retry_mission() -> void:
	if transitioning:
		return

	if not ResourceLoader.exists(OUTSIDE_SCENE):
		push_error("Missing OutsideLab scene: " + OUTSIDE_SCENE)
		return

	transitioning = true
	retry_button.disabled = true

	fade_overlay.move_to_front()
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.4)
	await tween.finished

	SpacecraftGameState.reset_progress()

	if get_tree().has_meta("space_vault_failed_scientist"):
		get_tree().remove_meta("space_vault_failed_scientist")

	var error: Error = get_tree().change_scene_to_file(OUTSIDE_SCENE)

	if error != OK:
		push_error("Failed to restart mission: " + str(error))
		transitioning = false
		retry_button.disabled = false
