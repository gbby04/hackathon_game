
extends Control

# ============================================================
# SPACE VAULT - CINEMATIC ESCAPE DIALOGUE
# Godot 4.7
#
# FIXED:
# - Joe, Matcha and Alien Joe use animated sprites
# - Horizontal spritesheets are split into frames
# - Only the current speaker appears
# - Alien Joe replaces normal Joe on reveal
# - Correct portrait scaling
#
# PRESERVED:
# - Starfield and Earth
# - Dialogue panel layout
# - Typewriter effect
# - Click / Enter / Space to advance
# - Animated dialogue arrow
# - Fade to Mission Results
#
# FILE:
# res://scripts/story/EscapeDialogue.gd
# ============================================================


# ============================================================
# SCENE PATHS
# ============================================================

const NEXT_SCENE: String = (
	"res://scenes/spacecraft/MissionResults.tscn"
)

const JOE_IDLE_PATH: String = (
	"res://assets/story/joe_idle_side-Sheet.png"
)

const MATCHA_PATH: String = (
	"res://assets/story/matcha.png"
)

const ALIEN_JOE_PATH: String = (
	"res://assets/story/alien_joe_peng.png"
)


# ============================================================
# ANIMATION SETTINGS
# ============================================================

# Normal Joe's known sheet:
# 4 horizontal frames, 64x64 each.
const JOE_FRAME_COUNT: int = 4
const JOE_FPS: float = 4.0

# Based on the sprites visible in your screenshots.
# Change these only if your actual sheets have
# a different number of horizontal frames.
const MATCHA_FRAME_COUNT: int = 7
const MATCHA_FPS: float = 5.0

const ALIEN_FRAME_COUNT: int = 4
const ALIEN_FPS: float = 4.0

# Maximum area allocated to each character.
# Individual frames are scaled, not entire sheets.
const PORTRAIT_MAX_WIDTH: float = 160.0
const PORTRAIT_MAX_HEIGHT: float = 118.0

const PORTRAIT_CENTRE: Vector2 = Vector2(135, 284)


# ============================================================
# SCREEN AND DIALOGUE LAYOUT
# ============================================================

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const TYPE_SPEED: float = 0.028

const PANEL_POSITION: Vector2 = Vector2(6, 208)
const PANEL_SIZE: Vector2 = Vector2(628, 146)

const SPEAKER_POSITION: Vector2 = Vector2(264, 223)
const SPEAKER_SIZE: Vector2 = Vector2(295, 22)

const TEXT_POSITION: Vector2 = Vector2(264, 252)
const TEXT_SIZE: Vector2 = Vector2(313, 79)

const DIALOGUE_FONT_SIZE: int = 15
const ARROW_POSITION: Vector2 = Vector2(596, 326)


# ============================================================
# COLOURS
# ============================================================

const BG: Color = Color("#02060e")
const PANEL_BG: Color = Color("#050505")
const PANEL_BORDER: Color = Color("#dddddd")

const NAME_COLOR: Color = Color("#b7b7b7")
const MATCHA_COLOR: Color = Color("#71dbff")

const TEXT_COLOR: Color = Color.WHITE
const ARROW_COLOR: Color = Color.WHITE


# ============================================================
# SPACE BACKGROUND
# ============================================================

class SpaceBackdrop:
	extends Control

	const SPACE: Color = Color("#02060e")
	const OCEAN: Color = Color("#367bc5")
	const LAND: Color = Color("#67b96a")
	const CLOUD: Color = Color("#dcefff")

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		draw_rect(
			Rect2(0, 0, 640, 360),
			SPACE
		)

		_draw_stars()
		_draw_earth()

	func _draw_stars() -> void:
		var points: Array[Vector2] = [
			Vector2(28, 24),
			Vector2(60, 76),
			Vector2(92, 43),
			Vector2(127, 18),
			Vector2(155, 62),
			Vector2(183, 103),
			Vector2(220, 32),
			Vector2(246, 69),
			Vector2(281, 15),
			Vector2(302, 90),
			Vector2(336, 44),
			Vector2(374, 83),
			Vector2(404, 20),
			Vector2(436, 62),
			Vector2(470, 23),
			Vector2(535, 20),
			Vector2(582, 49),
			Vector2(604, 38),
			Vector2(618, 110),
			Vector2(45, 128),
			Vector2(99, 142),
			Vector2(172, 135),
			Vector2(245, 124),
			Vector2(326, 139),
			Vector2(420, 132),
			Vector2(562, 165),
			Vector2(595, 190),
			Vector2(62, 196),
			Vector2(205, 193),
			Vector2(347, 189)
		]

		for i in range(points.size()):
			var radius: float = 1.0

			if i % 6 == 0:
				radius = 1.5

			draw_circle(
				points[i],
				radius,
				Color(1.0, 1.0, 1.0, 0.8)
			)

	func _draw_earth() -> void:
		var centre: Vector2 = Vector2(507, 101)

		draw_circle(
			centre,
			83.0,
			Color(0.17, 0.37, 0.75, 0.08)
		)

		draw_circle(
			centre,
			75.0,
			Color(0.24, 0.52, 0.92, 0.14)
		)

		draw_circle(
			centre,
			66.0,
			OCEAN
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(473, 62),
				Vector2(497, 57),
				Vector2(511, 67),
				Vector2(504, 81),
				Vector2(488, 86),
				Vector2(475, 76)
			]),
			LAND
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(505, 95),
				Vector2(527, 87),
				Vector2(544, 99),
				Vector2(541, 119),
				Vector2(525, 128),
				Vector2(510, 115)
			]),
			LAND
		)

		draw_colored_polygon(
			PackedVector2Array([
				Vector2(472, 109),
				Vector2(488, 103),
				Vector2(499, 117),
				Vector2(494, 134),
				Vector2(480, 138),
				Vector2(469, 126)
			]),
			LAND
		)

		draw_line(
			Vector2(463, 94),
			Vector2(489, 94),
			CLOUD,
			3.0
		)

		draw_line(
			Vector2(508, 77),
			Vector2(536, 77),
			CLOUD,
			3.0
		)

		draw_line(
			Vector2(500, 140),
			Vector2(525, 140),
			CLOUD,
			3.0
		)

		draw_arc(
			centre,
			64.0,
			-1.1,
			1.1,
			35,
			Color(0.03, 0.10, 0.23, 0.6),
			9.0
		)

		draw_arc(
			centre,
			67.0,
			0.0,
			TAU,
			72,
			Color(0.48, 0.79, 1.0, 0.65),
			2.0
		)


# ============================================================
# STORY DIALOGUE
# ============================================================

var dialogue_lines: Array[Dictionary] = [
	{
		"speaker": "Joe Peng",
		"text": "Finally... I can go home."
	},
	{
		"speaker": "Joe Peng",
		"text": "No more laboratories. No more Scientists."
	},
	{
		"speaker": "Joe Peng",
		"text": "I never thought I'd miss the stars this much."
	},
	{
		"speaker": "Matcha",
		"text": "Trajectory stable, sir. Earth is now a safely decreasing concern."
	},
	{
		"speaker": "Joe Peng",
		"text": "Then take us home, Matcha.",
		"alien_reveal": true
	},
	{
		"speaker": "Matcha",
		"text": "With pleasure, sir."
	}
]


# ============================================================
# STATE
# ============================================================

var dialogue_index: int = 0

var transitioning: bool = false
var text_finished: bool = false

var current_full_text: String = ""
var displayed_characters: int = 0

var type_timer: float = 0.0
var arrow_time: float = 0.0


# ============================================================
# NODES
# ============================================================

var space_background: SpaceBackdrop
var dialogue_panel: Panel

var joe_portrait: AnimatedSprite2D
var matcha_portrait: AnimatedSprite2D
var alien_portrait: AnimatedSprite2D

var speaker_label: Label
var text_label: Label
var arrow_label: Label

var fade_overlay: ColorRect


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_scene()
	_show_current_line()


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	if transitioning:
		return

	arrow_time += delta

	arrow_label.position.y = (
		ARROW_POSITION.y
		+ sin(arrow_time * 4.0) * 2.0
	)

	arrow_label.visible = text_finished

	if text_finished:
		return

	type_timer += delta

	while type_timer >= TYPE_SPEED:
		type_timer -= TYPE_SPEED

		displayed_characters += 1

		if displayed_characters >= current_full_text.length():
			displayed_characters = current_full_text.length()
			text_finished = true

		text_label.visible_characters = displayed_characters

		if text_finished:
			break


# ============================================================
# INPUT
# ============================================================

func _input(event: InputEvent) -> void:
	if transitioning:
		return

	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			_handle_advance()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_advance()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_accept"):
		if not event.is_echo():
			_handle_advance()
			get_viewport().set_input_as_handled()


func _handle_advance() -> void:
	if not text_finished:
		_finish_text_immediately()
		return

	dialogue_index += 1

	if dialogue_index >= dialogue_lines.size():
		_finish_scene()
		return

	_show_current_line()


func _finish_text_immediately() -> void:
	displayed_characters = current_full_text.length()
	text_label.visible_characters = -1
	text_finished = true


# ============================================================
# BUILD SCENE
# ============================================================

func _build_scene() -> void:
	space_background = SpaceBackdrop.new()
	space_background.name = "SpaceBackdrop"
	space_background.position = Vector2.ZERO
	space_background.size = SCREEN_SIZE

	add_child(space_background)

	dialogue_panel = Panel.new()
	dialogue_panel.name = "DialoguePanel"
	dialogue_panel.position = PANEL_POSITION
	dialogue_panel.size = PANEL_SIZE
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = PANEL_BG
	style.border_color = PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)

	dialogue_panel.add_theme_stylebox_override(
		"panel",
		style
	)

	add_child(dialogue_panel)

	# Three independent animated portraits.
	# They all occupy the same character area.
	joe_portrait = _create_animated_portrait(
		"JoePortrait",
		JOE_IDLE_PATH,
		JOE_FRAME_COUNT,
		JOE_FPS
	)

	matcha_portrait = _create_animated_portrait(
		"MatchaPortrait",
		MATCHA_PATH,
		MATCHA_FRAME_COUNT,
		MATCHA_FPS
	)

	alien_portrait = _create_animated_portrait(
		"AlienJoePortrait",
		ALIEN_JOE_PATH,
		ALIEN_FRAME_COUNT,
		ALIEN_FPS
	)

	speaker_label = Label.new()
	speaker_label.position = SPEAKER_POSITION
	speaker_label.size = SPEAKER_SIZE
	speaker_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	speaker_label.add_theme_font_size_override(
		"font_size",
		13
	)

	speaker_label.add_theme_color_override(
		"font_color",
		NAME_COLOR
	)

	add_child(speaker_label)

	text_label = Label.new()
	text_label.position = TEXT_POSITION
	text_label.size = TEXT_SIZE

	text_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	text_label.add_theme_font_size_override(
		"font_size",
		DIALOGUE_FONT_SIZE
	)

	text_label.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)

	text_label.visible_characters = 0

	add_child(text_label)

	arrow_label = Label.new()
	arrow_label.text = "▼"
	arrow_label.position = ARROW_POSITION
	arrow_label.size = Vector2(22, 20)
	arrow_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	arrow_label.add_theme_font_size_override(
		"font_size",
		16
	)

	arrow_label.add_theme_color_override(
		"font_color",
		ARROW_COLOR
	)

	add_child(arrow_label)
	arrow_label.hide()

	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(fade_overlay)

	fade_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


# ============================================================
# SPRITESHEET ANIMATION LOADER
#
# Reads one horizontal row of frames.
#
# Example:
# 7 frames in a 224x32 sheet:
# frame width = 224 / 7 = 32
#
# It uses the entire sheet height as frame height.
# ============================================================

func _create_animated_portrait(
	node_name: String,
	texture_path: String,
	frame_count: int,
	fps: float
) -> AnimatedSprite2D:
	var portrait: AnimatedSprite2D = AnimatedSprite2D.new()

	portrait.name = node_name
	portrait.position = PORTRAIT_CENTRE

	portrait.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	add_child(portrait)
	portrait.hide()

	if not ResourceLoader.exists(texture_path):
		push_warning(
			"Missing portrait spritesheet: "
			+ texture_path
		)
		return portrait

	var texture: Texture2D = (
		load(texture_path) as Texture2D
	)

	if texture == null:
		push_warning(
			"Could not load portrait texture: "
			+ texture_path
		)
		return portrait

	if frame_count <= 0:
		push_warning(
			"Invalid frame count for: "
			+ texture_path
		)
		return portrait

	var sheet_width: int = texture.get_width()
	var sheet_height: int = texture.get_height()

	# Spritesheet must divide evenly into
	# the specified number of frames.
	if sheet_width % frame_count != 0:
		push_warning(
			"Spritesheet width "
			+ str(sheet_width)
			+ " is not divisible by "
			+ str(frame_count)
			+ " frames: "
			+ texture_path
		)
		return portrait

	var frame_width: int = int(
		sheet_width / frame_count
	)

	var frame_height: int = sheet_height

	if frame_width <= 0 or frame_height <= 0:
		return portrait

	var frames: SpriteFrames = SpriteFrames.new()

	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("idle")

	frames.set_animation_speed(
		"idle",
		fps
	)

	frames.set_animation_loop(
		"idle",
		true
	)

	for frame_index in range(frame_count):
		var frame_texture: AtlasTexture = (
			AtlasTexture.new()
		)

		frame_texture.atlas = texture

		frame_texture.region = Rect2(
			float(frame_index * frame_width),
			0.0,
			float(frame_width),
			float(frame_height)
		)

		frames.add_frame(
			"idle",
			frame_texture
		)

	portrait.sprite_frames = frames

	# Scale each individual sprite frame.
	# This prevents the entire horizontal strip
	# from being compressed into the portrait area.
	var scale_factor: float = min(
		PORTRAIT_MAX_WIDTH / float(frame_width),
		PORTRAIT_MAX_HEIGHT / float(frame_height)
	)

	# Prevent huge scaling on extremely tiny frames.
	scale_factor = min(scale_factor, 4.0)

	portrait.scale = Vector2(
		scale_factor,
		scale_factor
	)

	portrait.play("idle")

	print(
		"SPACE VAULT: Loaded ",
		node_name,
		" | frames: ",
		frame_count,
		" | frame size: ",
		frame_width,
		"x",
		frame_height
	)

	return portrait


# ============================================================
# PORTRAIT SWITCHING
# ============================================================

func _hide_all_portraits() -> void:
	joe_portrait.hide()
	matcha_portrait.hide()
	alien_portrait.hide()


func _show_speaker_portrait(
	speaker: String,
	line: Dictionary
) -> void:
	_hide_all_portraits()

	if speaker.to_lower() == "matcha":
		if matcha_portrait.sprite_frames != null:
			matcha_portrait.show()
		return

	var reveal_alien: bool = bool(
		line.get("alien_reveal", false)
	)

	if reveal_alien:
		if alien_portrait.sprite_frames != null:
			alien_portrait.show()
			return

	# Normal Joe is shown before the reveal,
	# or as a fallback if Alien Joe is missing.
	if joe_portrait.sprite_frames != null:
		joe_portrait.show()


# ============================================================
# DIALOGUE CONTROL
# ============================================================

func _show_current_line() -> void:
	if dialogue_index < 0:
		return

	if dialogue_index >= dialogue_lines.size():
		return

	var line: Dictionary = dialogue_lines[dialogue_index]

	var speaker: String = str(
		line.get("speaker", "")
	)

	current_full_text = str(
		line.get("text", "")
	)

	speaker_label.text = speaker

	displayed_characters = 0
	type_timer = 0.0
	text_finished = false

	# Set full text first to prevent the
	# words shifting while being typed.
	text_label.text = current_full_text
	text_label.visible_characters = 0

	arrow_label.hide()

	if speaker.to_lower() == "matcha":
		speaker_label.add_theme_color_override(
			"font_color",
			MATCHA_COLOR
		)
	else:
		speaker_label.add_theme_color_override(
			"font_color",
			NAME_COLOR
		)

	_show_speaker_portrait(
		speaker,
		line
	)


# ============================================================
# END SCENE
# ============================================================

func _finish_scene() -> void:
	if transitioning:
		return

	transitioning = true
	arrow_label.hide()

	var tween: Tween = create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		0.65
	)

	await tween.finished

	if not ResourceLoader.exists(NEXT_SCENE):
		push_error(
			"Missing Mission Results scene: "
			+ NEXT_SCENE
		)
		return

	var error: Error = (
		get_tree().change_scene_to_file(
			NEXT_SCENE
		)
	)

	if error != OK:
		push_error(
			"Failed to open Mission Results. "
			+ "Godot error: "
			+ str(error)
		)
