
extends Control

# ============================================================
# SPACE VAULT - OUTSIDE LAB
# Godot 4.7
#
# COMPLETE SCRIPT - BUTTON OVERLAP FIX
#
# - Joe exits laboratory
# - Four Scientists surround Joe
# - Scientist dialogue and animations
# - Scientists face Joe
# - Black dialogue panel
# - FIGHT requires button click
# - WORKBENCH required after victory
# - NEXT appears after visiting WORKBENCH
# - WORKBENCH and NEXT no longer overlap
# - Scientist progression and component rewards
# - Three failed simulations trigger GAME OVER
# - RETRY handled by FailureEnding
# - Final victory unlocks LAUNCH
# ============================================================


# ============================================================
# PATHS
# ============================================================

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const OUTSIDE_IMAGE: String = (
	"res://assets/story/outside_lab.png"
)

const JOE_IDLE_IMAGE: String = (
	"res://assets/story/joe_idle_side-Sheet.png"
)

const JOE_WALK_IMAGE: String = (
	"res://assets/story/joe_walk_front-Sheet.png"
)

const SCIENTIST_IMAGES: Dictionary = {
	"niq": "res://assets/battles/characters/scientists/dr_niq.png",
	"gabby": "res://assets/battles/characters/scientists/dr_gabby.png",
	"ahmed": "res://assets/battles/characters/scientists/dr_ahmed.png",
	"celine": "res://assets/battles/characters/scientists/dr_celine.png"
}

const BATTLE_SCENE: PackedScene = preload(
	"res://scenes/battles/ScientistBattle.tscn"
)

const BUILDER_SCENE: PackedScene = preload(
	"res://scenes/spacecraft/ShipBuilder.tscn"
)

const LAUNCH_SCENE_PATH: String = (
	"res://scenes/spacecraft/EscapeLaunch.tscn"
)

const FAILURE_SCENE_PATH: String = (
	"res://scenes/story/FailureEnding.tscn"
)


# ============================================================
# SCIENTISTS
# ============================================================

const SCIENTIST_ORDER: Array[String] = [
	"niq",
	"gabby",
	"ahmed",
	"celine"
]

const SCIENTIST_NAMES: Dictionary = {
	"niq": "DR. NIQ",
	"gabby": "DR. GABBY",
	"ahmed": "DR. AHMED",
	"celine": "DR. CELINE"
}


# ============================================================
# MAP POSITIONS
# ============================================================

const JOE_DOOR_POSITION: Vector2 = Vector2(329, 270)
const JOE_OUTSIDE_POSITION: Vector2 = Vector2(329, 318)
const LAUNCH_POSITION: Vector2 = Vector2(541, 255)

const SCIENTIST_POSITIONS: Dictionary = {
	"niq": Vector2(268, 295),
	"gabby": Vector2(289, 326),
	"ahmed": Vector2(374, 326),
	"celine": Vector2(396, 295)
}


# ============================================================
# CHARACTER SCALES
# ============================================================

const WORLD_JOE_IDLE_SCALE: Vector2 = Vector2(1.24, 1.24)
const WORLD_JOE_WALK_SCALE: Vector2 = Vector2(1.10, 1.10)
const WORLD_SCIENTIST_SCALE: Vector2 = Vector2(1.12, 1.12)

const FOCUS_JOE_SCALE: Vector2 = Vector2(3.65, 3.65)
const FOCUS_SCIENTIST_SCALE: Vector2 = Vector2(3.45, 3.45)

const FOCUS_JOE_POSITION: Vector2 = Vector2(150, 184)
const FOCUS_SCIENTIST_POSITION: Vector2 = Vector2(490, 183)


# ============================================================
# GAMEPLAY
# ============================================================

const MAX_FAILED_TESTS: int = 3


# ============================================================
# UI COLOURS
# ============================================================

const PANEL_BG: Color = Color("#050505")
const PANEL_BORDER: Color = Color("#e6e6e6")

const TEXT_MAIN: Color = Color("#ffffff")
const TEXT_MUTED: Color = Color("#bdbdbd")

const BUTTON_BG: Color = Color("#164a5e")
const BUTTON_HOVER: Color = Color("#237b96")
const BUTTON_BORDER: Color = Color("#72dce9")


# ============================================================
# UI POSITIONS
# ============================================================

const DIALOGUE_POSITION: Vector2 = Vector2(8, 259)
const DIALOGUE_SIZE: Vector2 = Vector2(624, 93)

const SPEAKER_POSITION: Vector2 = Vector2(22, 269)
const MESSAGE_POSITION: Vector2 = Vector2(22, 291)

const ARROW_POSITION: Vector2 = Vector2(585, 314)

# FIGHT / NEXT
const ACTION_POSITION: Vector2 = Vector2(548, 312)
const ACTION_SIZE: Vector2 = Vector2(69, 25)

# FIXED: WORKBENCH now ends at X = 525.
# NEXT starts at X = 548.
# This leaves a 23-pixel gap.
const WORKBENCH_POSITION: Vector2 = Vector2(365, 312)
const WORKBENCH_SIZE: Vector2 = Vector2(160, 25)

const LAUNCH_BUTTON_POSITION: Vector2 = Vector2(475, 312)
const LAUNCH_BUTTON_SIZE: Vector2 = Vector2(142, 29)


# ============================================================
# INTRO DIALOGUE
# ============================================================

const INTRO_DIALOGUE: Dictionary = {
	"niq": [
		{
			"speaker": "NARRATOR",
			"text": "Joe steps out of the laboratory, only to find four Scientists blocking his escape."
		},
		{
			"speaker": "DR. NIQ",
			"text": "Not another step! You are not taking our technology off this planet."
		},
		{
			"speaker": "JOE PENG",
			"text": "I am leaving Earth. You can either move or lose."
		},
		{
			"speaker": "DR. NIQ",
			"text": "Then let's see your spacecraft survive an eclipse without sunlight."
		},
		{
			"speaker": "MATCHA",
			"text": "A battery endurance challenge, sir. I recommend some competent engineering."
		}
	],

	"gabby": [
		{
			"speaker": "NARRATOR",
			"text": "Dr. Niq retreats. Dr. Gabby challenges Joe next."
		},
		{
			"speaker": "DR. GABBY",
			"text": "You survived Niq's test? Your rocket won't be so lucky with mine."
		},
		{
			"speaker": "JOE PENG",
			"text": "Are all Scientists this stubborn?"
		},
		{
			"speaker": "DR. GABBY",
			"text": "Let's see if your engine can overcome my additional payload."
		},
		{
			"speaker": "MATCHA",
			"text": "A gravity challenge, sir. Better propulsion would be a sensible investment."
		}
	],

	"ahmed": [
		{
			"speaker": "NARRATOR",
			"text": "With Gabby defeated, Dr. Ahmed becomes Joe's next opponent."
		},
		{
			"speaker": "DR. AHMED",
			"text": "You may be able to launch. But can you transmit science data through my jammer?"
		},
		{
			"speaker": "JOE PENG",
			"text": "I'll find a way."
		},
		{
			"speaker": "DR. AHMED",
			"text": "Then prove it. Your transmission window is closing."
		},
		{
			"speaker": "MATCHA",
			"text": "Communications interference, sir. I suggest reviewing our scanner and downlink."
		}
	],

	"celine": [
		{
			"speaker": "NARRATOR",
			"text": "Only Dr. Celine remains between Joe and the launch facility."
		},
		{
			"speaker": "DR. CELINE",
			"text": "You've defeated my colleagues. Impressive. But your escape ends here."
		},
		{
			"speaker": "JOE PENG",
			"text": "I've heard that three times already."
		},
		{
			"speaker": "DR. CELINE",
			"text": "Then pass every engineering challenge at once. Power, launch and communications."
		},
		{
			"speaker": "MATCHA",
			"text": "The final examination, sir. Let's make certain the rocket is prepared."
		}
	]
}


# ============================================================
# VICTORY DIALOGUE
# ============================================================

const VICTORY_DIALOGUE: Dictionary = {
	"niq": [
		{
			"speaker": "DR. NIQ",
			"text": "Impossible! Your battery survived my eclipse?"
		},
		{
			"speaker": "MATCHA",
			"text": "Indeed, Doctor. Three new components are now available to us."
		}
	],

	"gabby": [
		{
			"speaker": "DR. GABBY",
			"text": "You overcame the extra payload? How?"
		},
		{
			"speaker": "MATCHA",
			"text": "Rather effective engineering, Doctor. Three more upgrades secured."
		}
	],

	"ahmed": [
		{
			"speaker": "DR. AHMED",
			"text": "Your data transmission succeeded?"
		},
		{
			"speaker": "MATCHA",
			"text": "Correct. We shall make good use of your three additional components."
		}
	],

	"celine": [
		{
			"speaker": "DR. CELINE",
			"text": "Every test passed. You've earned your escape."
		},
		{
			"speaker": "JOE PENG",
			"text": "Finally. Time to leave."
		},
		{
			"speaker": "MATCHA",
			"text": "All Scientists defeated, sir. The launch facility awaits."
		}
	]
}


# ============================================================
# STATE
# ============================================================

var mode: String = "entrance"
var current_boss_id: String = ""

var dialogue_phase: String = "intro"
var dialogue_lines: Array = []
var dialogue_index: int = 0

var transitioning: bool = false

var failed_tests: int = 0
var observed_turn: int = 1
var observed_hp: int = 100

var workbench_visited: bool = false
var action_required: bool = false


# ============================================================
# NODES
# ============================================================

var background: TextureRect

var world_layer: Node2D
var joe_world: AnimatedSprite2D
var scientist_world: Dictionary = {}

var shade: ColorRect
var focus_layer: Node2D
var joe_focus: AnimatedSprite2D
var scientist_focus: AnimatedSprite2D

var ui_layer: Control
var dialogue_panel: Panel
var speaker_label: Label
var message_label: Label

var next_button: Button
var workbench_button: Button

var fade_overlay: ColorRect
var game_over_label: Label

var battle: Control = null
var builder: Control = null


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_create_background()
	_create_world()
	_create_focus()
	_create_ui()
	_create_fade()

	_start_story()


# ============================================================
# BACKGROUND
# ============================================================

func _create_background() -> void:
	background = TextureRect.new()
	background.name = "OutsideLabBackground"

	background.position = Vector2.ZERO
	background.size = SCREEN_SIZE

	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE

	background.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	background.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	if ResourceLoader.exists(OUTSIDE_IMAGE):
		background.texture = load(OUTSIDE_IMAGE) as Texture2D
	else:
		push_error("Missing background: " + OUTSIDE_IMAGE)

	add_child(background)


# ============================================================
# SPRITE HELPERS
# ============================================================

func _build_frames(
	texture: Texture2D,
	frame_count: int,
	frame_width: int,
	frame_height: int,
	fps: float
) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()

	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("idle")
	frames.set_animation_speed("idle", fps)
	frames.set_animation_loop("idle", true)

	for index in range(frame_count):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture

		atlas.region = Rect2(
			float(index * frame_width),
			0.0,
			float(frame_width),
			float(frame_height)
		)

		frames.add_frame("idle", atlas)

	return frames


func _set_animation(
	target: AnimatedSprite2D,
	path: String,
	frame_count: int,
	frame_width: int,
	frame_height: int,
	fps: float
) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Missing sprite sheet: " + path)
		target.hide()
		return

	var texture: Texture2D = load(path) as Texture2D

	if texture == null:
		target.hide()
		return

	var required_width: int = frame_count * frame_width

	if (
		texture.get_width() < required_width
		or texture.get_height() < frame_height
	):
		push_warning("Unexpected sprite dimensions: " + path)
		target.hide()
		return

	target.sprite_frames = _build_frames(
		texture,
		frame_count,
		frame_width,
		frame_height,
		fps
	)

	target.play("idle")
	target.show()


# ============================================================
# JOE ANIMATIONS
# ============================================================

func _play_joe_idle() -> void:
	joe_world.scale = WORLD_JOE_IDLE_SCALE

	_set_animation(
		joe_world,
		JOE_IDLE_IMAGE,
		4,
		64,
		64,
		4.0
	)


func _play_joe_walk() -> void:
	joe_world.scale = WORLD_JOE_WALK_SCALE

	_set_animation(
		joe_world,
		JOE_WALK_IMAGE,
		6,
		48,
		48,
		8.0
	)


# ============================================================
# WORLD
# ============================================================

func _create_world() -> void:
	world_layer = Node2D.new()
	world_layer.name = "WorldLayer"
	add_child(world_layer)

	joe_world = AnimatedSprite2D.new()
	joe_world.name = "JoeWorld"
	joe_world.position = JOE_DOOR_POSITION

	joe_world.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	world_layer.add_child(joe_world)

	_play_joe_idle()

	for scientist_id in SCIENTIST_ORDER:
		var npc: AnimatedSprite2D = AnimatedSprite2D.new()

		npc.name = "Scientist_" + scientist_id
		npc.position = SCIENTIST_POSITIONS[scientist_id]
		npc.scale = WORLD_SCIENTIST_SCALE

		npc.texture_filter = (
			CanvasItem.TEXTURE_FILTER_NEAREST
		)

		world_layer.add_child(npc)

		_set_animation(
			npc,
			str(SCIENTIST_IMAGES[scientist_id]),
			4,
			64,
			64,
			4.0
		)

		if scientist_id == "niq" or scientist_id == "gabby":
			npc.flip_h = false
		else:
			npc.flip_h = true

		scientist_world[scientist_id] = npc


# ============================================================
# DIALOGUE CHARACTERS
# ============================================================

func _create_focus() -> void:
	shade = ColorRect.new()
	shade.position = Vector2.ZERO
	shade.size = SCREEN_SIZE
	shade.color = Color(0.03, 0.06, 0.10, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.hide()
	add_child(shade)

	focus_layer = Node2D.new()
	focus_layer.name = "FocusLayer"
	add_child(focus_layer)

	joe_focus = AnimatedSprite2D.new()
	joe_focus.name = "JoeFocus"
	joe_focus.position = FOCUS_JOE_POSITION
	joe_focus.scale = FOCUS_JOE_SCALE

	joe_focus.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	focus_layer.add_child(joe_focus)

	_set_animation(
		joe_focus,
		JOE_IDLE_IMAGE,
		4,
		64,
		64,
		4.0
	)

	joe_focus.hide()

	scientist_focus = AnimatedSprite2D.new()
	scientist_focus.name = "ScientistFocus"
	scientist_focus.position = FOCUS_SCIENTIST_POSITION
	scientist_focus.scale = FOCUS_SCIENTIST_SCALE

	scientist_focus.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	focus_layer.add_child(scientist_focus)
	scientist_focus.hide()


func _show_focus() -> void:
	shade.show()
	joe_world.hide()

	if scientist_world.has(current_boss_id):
		var npc: AnimatedSprite2D = scientist_world[current_boss_id]
		npc.hide()

	if SCIENTIST_IMAGES.has(current_boss_id):
		_set_animation(
			scientist_focus,
			str(SCIENTIST_IMAGES[current_boss_id]),
			4,
			64,
			64,
			4.0
		)

	joe_focus.show()
	scientist_focus.show()

	_update_speaker_focus()


func _hide_focus() -> void:
	shade.hide()
	joe_focus.hide()
	scientist_focus.hide()

	joe_world.show()
	_refresh_scientists()


func _update_speaker_focus() -> void:
	var speaker: String = speaker_label.text

	joe_focus.modulate = Color.WHITE
	scientist_focus.modulate = Color.WHITE

	if speaker == "JOE PENG":
		scientist_focus.modulate = Color(
			0.58, 0.64, 0.70, 1.0
		)
	elif speaker.begins_with("DR."):
		joe_focus.modulate = Color(
			0.58, 0.64, 0.70, 1.0
		)


# ============================================================
# SCIENTIST VISIBILITY
# ============================================================

func _refresh_scientists() -> void:
	for scientist_id in SCIENTIST_ORDER:
		if not scientist_world.has(scientist_id):
			continue

		var npc: AnimatedSprite2D = scientist_world[scientist_id]

		if SpacecraftGameState.has_defeated_scientist(scientist_id):
			npc.hide()
		else:
			npc.show()


# ============================================================
# UI LABEL
# ============================================================

func _make_label(
	value: String,
	at: Vector2,
	dimensions: Vector2,
	font_size: int,
	colour: Color
) -> Label:
	var result: Label = Label.new()

	result.text = value
	result.position = at
	result.size = dimensions

	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	result.add_theme_font_size_override(
		"font_size",
		font_size
	)

	result.add_theme_color_override(
		"font_color",
		colour
	)

	result.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ui_layer.add_child(result)

	return result


# ============================================================
# UI BUTTON
# ============================================================

func _make_button(
	value: String,
	at: Vector2,
	dimensions: Vector2
) -> Button:
	var result: Button = Button.new()

	result.text = value
	result.position = at
	result.size = dimensions
	result.focus_mode = Control.FOCUS_NONE

	result.add_theme_font_size_override("font_size", 12)

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = BUTTON_BG
	normal.border_color = BUTTON_BORDER
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = BUTTON_HOVER

	result.add_theme_stylebox_override("normal", normal)
	result.add_theme_stylebox_override("hover", hover)
	result.add_theme_stylebox_override("pressed", normal)
	result.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	result.add_theme_color_override("font_color", Color.WHITE)
	result.add_theme_color_override("font_hover_color", Color.WHITE)
	result.add_theme_color_override("font_pressed_color", Color.WHITE)

	ui_layer.add_child(result)

	return result


# ============================================================
# CREATE UI
# ============================================================

func _create_ui() -> void:
	ui_layer = Control.new()
	ui_layer.name = "StoryUI"
	ui_layer.position = Vector2.ZERO
	ui_layer.size = SCREEN_SIZE
	ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_layer)

	dialogue_panel = Panel.new()
	dialogue_panel.name = "DialoguePanel"
	dialogue_panel.position = DIALOGUE_POSITION
	dialogue_panel.size = DIALOGUE_SIZE
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)

	dialogue_panel.add_theme_stylebox_override("panel", style)
	dialogue_panel.gui_input.connect(_on_dialogue_panel_input)

	ui_layer.add_child(dialogue_panel)

	speaker_label = _make_label(
		"",
		SPEAKER_POSITION,
		Vector2(420, 18),
		12,
		TEXT_MUTED
	)

	message_label = _make_label(
		"",
		MESSAGE_POSITION,
		Vector2(588, 30),
		11,
		TEXT_MAIN
	)

	next_button = _make_button(
		"▼",
		ARROW_POSITION,
		Vector2(24, 24)
	)

	next_button.pressed.connect(_on_next_pressed)

	workbench_button = _make_button(
		"WORKBENCH",
		WORKBENCH_POSITION,
		WORKBENCH_SIZE
	)

	workbench_button.pressed.connect(_open_workbench)

	_hide_dialogue()


# ============================================================
# DIALOGUE INPUT
# ============================================================

func _on_dialogue_panel_input(event: InputEvent) -> void:
	if transitioning:
		return

	if action_required or mode == "between":
		return

	if mode != "dialogue":
		return

	var advance: bool = false

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			advance = true

	elif event is InputEventScreenTouch:
		if event.pressed:
			advance = true

	if advance:
		dialogue_panel.accept_event()
		_advance_normal_dialogue()


# ============================================================
# ARROW STYLE
# ============================================================

func _set_next_as_arrow() -> void:
	action_required = false

	next_button.flat = true
	next_button.text = "▼"
	next_button.position = ARROW_POSITION
	next_button.size = Vector2(24, 24)

	next_button.add_theme_font_size_override("font_size", 20)

	for colour_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color"
	]:
		next_button.add_theme_color_override(
			colour_name,
			Color.WHITE
		)

	var transparent: StyleBoxEmpty = StyleBoxEmpty.new()

	for style_name in [
		"normal",
		"hover",
		"pressed",
		"focus",
		"disabled"
	]:
		next_button.add_theme_stylebox_override(
			style_name,
			transparent
		)

	next_button.show()


# ============================================================
# ACTION STYLE
# ============================================================

func _set_next_as_action(action_text: String) -> void:
	action_required = true

	next_button.flat = false
	next_button.text = action_text
	next_button.position = ACTION_POSITION
	next_button.size = ACTION_SIZE

	next_button.add_theme_font_size_override("font_size", 12)

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = BUTTON_BG
	normal.border_color = BUTTON_BORDER
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = BUTTON_HOVER

	next_button.add_theme_stylebox_override("normal", normal)
	next_button.add_theme_stylebox_override("hover", hover)
	next_button.add_theme_stylebox_override("pressed", normal)
	next_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	next_button.show()


# ============================================================
# DIALOGUE VISIBILITY
# ============================================================

func _show_dialogue() -> void:
	dialogue_panel.show()
	speaker_label.show()
	message_label.show()
	next_button.show()
	workbench_button.hide()


func _hide_dialogue() -> void:
	dialogue_panel.hide()
	speaker_label.hide()
	message_label.hide()
	next_button.hide()
	workbench_button.hide()


# ============================================================
# FADE
# ============================================================

func _create_fade() -> void:
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.position = Vector2.ZERO
	fade_overlay.size = SCREEN_SIZE
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(fade_overlay)

	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.position = Vector2(0, 143)
	game_over_label.size = Vector2(640, 70)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 34)
	game_over_label.add_theme_color_override(
		"font_color",
		Color("#ff8b8b")
	)

	fade_overlay.add_child(game_over_label)
	game_over_label.hide()


func _fade_to_black(duration: float) -> void:
	fade_overlay.move_to_front()
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween: Tween = create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		duration
	)

	await tween.finished


func _fade_from_black(duration: float) -> void:
	fade_overlay.move_to_front()

	var tween: Tween = create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished

	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ============================================================
# STORY START
# ============================================================

func _start_story() -> void:
	_refresh_scientists()

	var next_id: String = SpacecraftGameState.get_next_scientist_id()

	if next_id.is_empty():
		_show_final_stage()
		return

	_start_encounter(next_id, true)


# ============================================================
# START ENCOUNTER
# ============================================================

func _start_encounter(
	scientist_id: String,
	animate_entrance: bool
) -> void:
	if transitioning:
		return

	current_boss_id = scientist_id
	mode = "entrance"
	transitioning = true
	action_required = false
	workbench_visited = false

	_hide_dialogue()
	_hide_focus()
	_refresh_scientists()

	for scientist_id_key in SCIENTIST_ORDER:
		if scientist_world.has(scientist_id_key):
			var npc: AnimatedSprite2D = scientist_world[scientist_id_key]
			npc.position = SCIENTIST_POSITIONS[scientist_id_key]

	if animate_entrance:
		joe_world.position = JOE_DOOR_POSITION
		_play_joe_walk()

		var entrance: Tween = create_tween()

		entrance.tween_property(
			joe_world,
			"position",
			JOE_OUTSIDE_POSITION,
			1.10
		)

		await entrance.finished
		_play_joe_idle()
	else:
		joe_world.position = JOE_OUTSIDE_POSITION
		_play_joe_idle()
		await get_tree().create_timer(0.20).timeout

	transitioning = false
	_start_dialogue("intro")


# ============================================================
# START DIALOGUE
# ============================================================

func _start_dialogue(phase: String) -> void:
	mode = "dialogue"
	dialogue_phase = phase
	dialogue_index = 0
	action_required = false

	if phase == "intro":
		dialogue_lines = INTRO_DIALOGUE.get(
			current_boss_id,
			[]
		).duplicate(true)
	else:
		dialogue_lines = VICTORY_DIALOGUE.get(
			current_boss_id,
			[]
		).duplicate(true)

	_show_dialogue()
	_show_focus()
	_display_line()


# ============================================================
# DISPLAY LINE
# ============================================================

func _display_line() -> void:
	if dialogue_index >= dialogue_lines.size():
		_complete_dialogue()
		return

	var line: Dictionary = dialogue_lines[dialogue_index]

	speaker_label.text = str(line.get("speaker", ""))
	message_label.text = str(line.get("text", ""))

	var is_final_intro_line: bool = (
		dialogue_phase == "intro"
		and dialogue_index == dialogue_lines.size() - 1
	)

	if is_final_intro_line:
		_set_next_as_action("FIGHT")
	else:
		_set_next_as_arrow()

	_update_speaker_focus()


# ============================================================
# NORMAL DIALOGUE ADVANCE
# ============================================================

func _advance_normal_dialogue() -> void:
	if transitioning:
		return

	if mode != "dialogue":
		return

	if action_required:
		return

	dialogue_index += 1
	_display_line()


# ============================================================
# NEXT / FIGHT / LAUNCH
# ============================================================

func _on_next_pressed() -> void:
	if transitioning:
		return

	if mode == "dialogue":
		if action_required:
			if next_button.text == "FIGHT":
				_complete_dialogue()
			return

		_advance_normal_dialogue()
		return

	if mode == "between":
		if is_instance_valid(builder):
			return

		var next_id: String = SpacecraftGameState.get_next_scientist_id()

		if next_id.is_empty():
			if next_button.text == "LAUNCH":
				_begin_launch()
			return

		if not workbench_visited:
			return

		if next_button.text != "NEXT":
			return

		_transition_to_next(next_id)


# ============================================================
# COMPLETE DIALOGUE
# ============================================================

func _complete_dialogue() -> void:
	_hide_dialogue()
	_hide_focus()
	action_required = false

	if dialogue_phase == "intro":
		_enter_battle()
	else:
		_show_between_battles()


# ============================================================
# ENTER BATTLE
# ============================================================

func _enter_battle() -> void:
	if transitioning:
		return

	if not SpacecraftGameState.can_challenge_scientist(current_boss_id):
		push_warning("Scientist locked: " + current_boss_id)
		return

	transitioning = true
	mode = "transition"

	await _fade_to_black(0.45)
	_create_battle()
	await _fade_from_black(0.45)

	transitioning = false


# ============================================================
# CREATE BATTLE
# ============================================================

func _create_battle() -> void:
	battle = BATTLE_SCENE.instantiate() as Control

	if battle == null:
		push_error("ScientistBattle.tscn needs a Control root.")
		mode = "entrance"
		return

	battle.set("boss_id", current_boss_id)

	add_child(battle)
	battle.position = Vector2.ZERO
	battle.size = SCREEN_SIZE

	if battle.has_signal("battle_won"):
		battle.connect(
			"battle_won",
			Callable(self, "_on_battle_won")
		)
	else:
		push_error("ScientistBattle is missing battle_won.")

	failed_tests = 0
	observed_turn = 1
	observed_hp = 100

	mode = "battle"
	fade_overlay.move_to_front()


# ============================================================
# BATTLE MONITORING
# ============================================================

func _process(_delta: float) -> void:
	if mode != "battle":
		return

	if transitioning:
		return

	if not is_instance_valid(battle):
		return

	if bool(battle.get("busy")):
		return

	if bool(battle.get("battle_finished")):
		return

	var current_turn: int = int(battle.get("turn_number"))
	var current_hp: int = int(battle.get("boss_hp"))

	if current_turn <= observed_turn:
		return

	if current_hp >= observed_hp:
		failed_tests += 1

		if failed_tests >= MAX_FAILED_TESTS:
			_trigger_game_over()
			return

	observed_turn = current_turn
	observed_hp = current_hp


# ============================================================
# SCIENTIST VICTORY
# ============================================================

func _on_battle_won(scientist_id: String) -> void:
	if mode != "battle":
		return

	if transitioning:
		return

	if scientist_id != current_boss_id:
		push_warning("Unexpected victory from: " + scientist_id)
		return

	if not SpacecraftGameState.has_defeated_scientist(scientist_id):
		var reward_result: Dictionary = (
			SpacecraftGameState.complete_scientist_battle(
				scientist_id
			)
		)

		if not bool(reward_result.get("success", false)):
			push_error(
				"Could not record victory against "
				+ scientist_id
				+ ": "
				+ str(reward_result.get("reason", "Unknown error"))
			)
			return

	if not SpacecraftGameState.has_defeated_scientist(scientist_id):
		push_error(
			"Scientist victory was not saved: "
			+ scientist_id
		)
		return

	_finish_victory()


# ============================================================
# VICTORY TRANSITION
# ============================================================

func _finish_victory() -> void:
	transitioning = true
	mode = "transition"

	await _fade_to_black(0.45)

	_remove_battle()
	_refresh_scientists()

	joe_world.position = JOE_OUTSIDE_POSITION
	_play_joe_idle()

	await _fade_from_black(0.45)

	transitioning = false
	_start_dialogue("victory")


func _remove_battle() -> void:
	if is_instance_valid(battle):
		battle.queue_free()

	battle = null


# ============================================================
# BETWEEN BATTLES
# ============================================================

func _show_between_battles() -> void:
	mode = "between"

	_show_dialogue()
	_show_focus()

	speaker_label.text = "MATCHA"
	action_required = true

	var next_id: String = SpacecraftGameState.get_next_scientist_id()

	if next_id.is_empty():
		message_label.text = (
			"All four Scientists defeated, sir. "
			+ "The launch facility awaits."
		)

		_set_next_as_action("LAUNCH")
		_configure_final_launch_button()
	else:
		workbench_visited = false

		message_label.text = (
			"Three upgrades unlocked, sir. "
			+ "Open WORKBENCH to prepare "
			+ "for the next Scientist."
		)

		next_button.hide()
		workbench_button.disabled = false
		workbench_button.position = WORKBENCH_POSITION
		workbench_button.size = WORKBENCH_SIZE
		workbench_button.show()

	_update_speaker_focus()


# ============================================================
# TRANSITION TO NEXT SCIENTIST
# ============================================================

func _transition_to_next(next_id: String) -> void:
	if transitioning:
		return

	transitioning = true
	mode = "transition"

	await _fade_to_black(0.45)

	_hide_dialogue()
	_hide_focus()

	current_boss_id = next_id

	transitioning = false
	_start_encounter(next_id, false)

	await _fade_from_black(0.45)


# ============================================================
# OPEN WORKBENCH
# ============================================================

func _open_workbench() -> void:
	if mode != "between":
		return

	if transitioning:
		return

	if SpacecraftGameState.get_next_scientist_id().is_empty():
		return

	if is_instance_valid(builder):
		return

	builder = BUILDER_SCENE.instantiate() as Control

	if builder == null:
		push_error("ShipBuilder.tscn needs a Control root.")
		return

	add_child(builder)
	builder.position = Vector2.ZERO
	builder.size = SCREEN_SIZE

	if builder.has_signal("close_requested"):
		builder.connect(
			"close_requested",
			Callable(self, "_close_workbench")
		)

	fade_overlay.move_to_front()


# ============================================================
# CLOSE WORKBENCH
# ============================================================

func _close_workbench() -> void:
	if is_instance_valid(builder):
		builder.queue_free()

	builder = null
	workbench_visited = true

	if mode != "between":
		return

	var next_id: String = SpacecraftGameState.get_next_scientist_id()

	if next_id.is_empty():
		return

	message_label.text = (
		"Spacecraft ready for review, sir. "
		+ "Select NEXT when you are prepared."
	)

	_set_next_as_action("NEXT")

	# FIX: Keep the buttons separate.
	next_button.position = ACTION_POSITION
	next_button.size = ACTION_SIZE

	workbench_button.position = WORKBENCH_POSITION
	workbench_button.size = WORKBENCH_SIZE
	workbench_button.show()
	workbench_button.disabled = false


# ============================================================
# GAME OVER
# ============================================================

func _trigger_game_over() -> void:
	if transitioning:
		return

	_run_game_over()


func _run_game_over() -> void:
	transitioning = true
	mode = "game_over"

	get_tree().set_meta(
		"space_vault_failed_scientist",
		current_boss_id
	)

	await _fade_to_black(0.45)

	if not is_inside_tree():
		return

	# Progression resets only on RETRY.
	if not ResourceLoader.exists(FAILURE_SCENE_PATH):
		push_error(
			"Missing GAME OVER scene: "
			+ FAILURE_SCENE_PATH
		)

		await _fade_from_black(0.45)

		transitioning = false
		mode = "battle"
		return

	var error: Error = (
		get_tree().change_scene_to_file(
			FAILURE_SCENE_PATH
		)
	)

	if error != OK:
		push_error(
			"Failed to open GAME OVER: "
			+ str(error)
		)

		await _fade_from_black(0.45)

		transitioning = false
		mode = "battle"


# ============================================================
# FINAL STAGE
# ============================================================

func _show_final_stage() -> void:
	current_boss_id = ""
	mode = "between"

	action_required = true
	workbench_visited = true

	_refresh_scientists()

	shade.hide()
	joe_focus.hide()
	scientist_focus.hide()

	joe_world.show()
	joe_world.position = JOE_OUTSIDE_POSITION
	_play_joe_idle()

	_show_dialogue()

	speaker_label.text = "MATCHA"

	message_label.text = (
		"All four Scientists defeated, sir. "
		+ "The launch facility awaits."
	)

	_set_next_as_action("LAUNCH")
	_configure_final_launch_button()


# ============================================================
# FINAL LAUNCH BUTTON
# ============================================================

func _configure_final_launch_button() -> void:
	workbench_button.hide()
	workbench_button.disabled = true

	next_button.show()
	next_button.disabled = false
	next_button.position = LAUNCH_BUTTON_POSITION
	next_button.size = LAUNCH_BUTTON_SIZE


# ============================================================
# BEGIN LAUNCH
# ============================================================

func _begin_launch() -> void:
	if transitioning:
		return

	if not SpacecraftGameState.is_final_escape_unlocked():
		push_warning(
			"Launch locked. Defeat all four Scientists."
		)
		return

	transitioning = true
	mode = "transition"

	_hide_dialogue()
	_hide_focus()

	_play_joe_walk()

	var walk: Tween = create_tween()

	walk.tween_property(
		joe_world,
		"position",
		LAUNCH_POSITION,
		1.4
	)

	await walk.finished

	_play_joe_idle()

	await _fade_to_black(0.55)

	if ResourceLoader.exists(LAUNCH_SCENE_PATH):
		var error: Error = (
			get_tree().change_scene_to_file(
				LAUNCH_SCENE_PATH
			)
		)

		if error != OK:
			push_error(
				"Could not open launch scene: "
				+ str(error)
			)
	else:
		push_error(
			"Missing launch scene: "
			+ LAUNCH_SCENE_PATH
		)

		await _fade_from_black(0.4)

		transitioning = false
		_show_final_stage()
