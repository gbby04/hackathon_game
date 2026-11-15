
extends Control

# ==========================================
# SPACE VAULT - STORY SEQUENCE
# Godot 4.7
#
# Joe leaves the laboratory.
# Four Scientists confront him in order.
# Each Scientist speaks before battle.
#
# Lose 3 engineering simulations:
# - Fade to black
# - Reset saved progression
# - Remove earned components
# - Clear equipped rocket parts
# - Restart Dr. Niq's encounter
#
# Win:
# - Receive existing battle rewards
# - Continue to next Scientist
# - Reach final launch after Dr. Celine
#
# This controller uses existing scenes
# and does not replace ScientistBattle.gd.
# ==========================================

const BATTLE_SCENE: PackedScene = preload(
	"res://scenes/battles/ScientistBattle.tscn"
)

const BUILDER_SCENE: PackedScene = preload(
	"res://scenes/spacecraft/ShipBuilder.tscn"
)

const LAUNCH_SCENE_PATH: String = (
	"res://scenes/spacecraft/EscapeLaunch.tscn"
)

const JOE_TEXTURE_PATH: String = (
	"res://assets/battles/characters/joe_peng/joe_peng.png"
)

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const MAX_FAILED_SIMULATIONS: int = 3

const BG: Color = Color("#101c2c")
const PANEL: Color = Color("#172b40")
const LIGHT: Color = Color("#e9f6ff")
const MUTED: Color = Color("#a9bcd0")
const ACCENT: Color = Color("#6bd9e6")
const WARNING: Color = Color("#ffc87f")

const SCIENTISTS: Array[String] = [
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

# Dialogue occurs before each fight.
# The last line is followed by battle.

const ENCOUNTERS: Dictionary = {
	"niq": [
		{
			"speaker": "NARRATOR",
			"text": "Joe Peng approaches the laboratory exit. His escape rocket is still unfinished."
		},
		{
			"speaker": "MATCHA",
			"text": "The exit is ahead, sir. I recommend departing before anyone notices the missing equipment."
		},
		{
			"speaker": "DR. NIQ",
			"text": "Not another step! You think you can escape Earth with that collection of spare parts?"
		},
		{
			"speaker": "JOE PENG",
			"text": "I don't need your permission. I just need my rocket."
		},
		{
			"speaker": "DR. NIQ",
			"text": "Then survive my eclipse simulation. Let's see how long your battery lasts without sunlight!"
		},
		{
			"speaker": "MATCHA",
			"text": "A power endurance challenge, sir. How terribly welcoming. Shall we proceed?"
		}
	],

	"gabby": [
		{
			"speaker": "NARRATOR",
			"text": "Dr. Niq retreats. Joe moves towards the next laboratory corridor, carrying his newly acquired components."
		},
		{
			"speaker": "DR. GABBY",
			"text": "So you're the alien causing trouble in my laboratory!"
		},
		{
			"speaker": "JOE PENG",
			"text": "I only want to get off this planet."
		},
		{
			"speaker": "DR. GABBY",
			"text": "Then let's see if your rocket can overcome my gravity challenge. I've added a little extra weight!"
		},
		{
			"speaker": "MATCHA",
			"text": "A little extra weight, sir. Scientists do have an interesting definition of 'little'."
		}
	],

	"ahmed": [
		{
			"speaker": "NARRATOR",
			"text": "Joe defeats Dr. Gabby and heads towards the communications laboratory."
		},
		{
			"speaker": "DR. AHMED",
			"text": "Your rocket may fly, alien. But without communication, you'll be completely lost."
		},
		{
			"speaker": "JOE PENG",
			"text": "You really think you can stop me with a radio?"
		},
		{
			"speaker": "DR. AHMED",
			"text": "Not a radio. A signal jammer. Let's see how much science data you can transmit!"
		},
		{
			"speaker": "MATCHA",
			"text": "Communications interference detected, sir. I suggest we make our response considerably clearer."
		}
	],

	"celine": [
		{
			"speaker": "NARRATOR",
			"text": "Joe passes the communications laboratory. Only one Scientist stands between him and the launch facility."
		},
		{
			"speaker": "DR. CELINE",
			"text": "You've defeated the others. Impressive. But your luck ends here."
		},
		{
			"speaker": "JOE PENG",
			"text": "I'm leaving Earth. Nothing you do will change that."
		},
		{
			"speaker": "DR. CELINE",
			"text": "Then prove your spacecraft can survive an eclipse, launch safely and maintain communications. All at once!"
		},
		{
			"speaker": "MATCHA",
			"text": "The final examination, sir. I trust you've been paying attention to your engineering lessons."
		}
	]
}

# Dialogue shown after victory.
const VICTORY_DIALOGUE: Dictionary = {
	"niq": [
		{
			"speaker": "DR. NIQ",
			"text": "Impossible! Your power systems survived my eclipse?"
		},
		{
			"speaker": "MATCHA",
			"text": "Indeed, Doctor. Your calculations were educational, if somewhat unsuccessful."
		},
		{
			"speaker": "NARRATOR",
			"text": "Joe recovers three spacecraft components. A new Scientist approaches."
		}
	],

	"gabby": [
		{
			"speaker": "DR. GABBY",
			"text": "You overcame the extra mass? That engine should never have worked!"
		},
		{
			"speaker": "MATCHA",
			"text": "An unfortunate day for gravity, sir. Shall we continue?"
		},
		{
			"speaker": "NARRATOR",
			"text": "Joe collects three more components and advances into the communications laboratory."
		}
	],

	"ahmed": [
		{
			"speaker": "DR. AHMED",
			"text": "You transmitted the data through my jammer? How?"
		},
		{
			"speaker": "MATCHA",
			"text": "Excellent engineering, Doctor. And a modest amount of competence from my pilot."
		},
		{
			"speaker": "NARRATOR",
			"text": "Joe earns three additional components. Dr. Celine waits near the launch facility."
		}
	],

	"celine": [
		{
			"speaker": "DR. CELINE",
			"text": "You passed every test. I underestimated you."
		},
		{
			"speaker": "JOE PENG",
			"text": "I told you. I'm getting off Earth."
		},
		{
			"speaker": "MATCHA",
			"text": "All four Scientists defeated, sir. An extraordinary amount of paperwork avoided."
		},
		{
			"speaker": "NARRATOR",
			"text": "Joe collects the final three components. The rocket launch facility is now accessible."
		}
	]
}

var current_boss_id: String = "niq"

var dialogue_lines: Array = []
var dialogue_index: int = 0

var scene_mode: String = "intro"
var busy: bool = false
var failed_simulations: int = 0

var last_turn: int = 1
var last_hp: int = 100

var battle: Control = null
var builder: Control = null

var title_label: Label
var speaker_label: Label
var dialogue_label: Label
var status_label: Label

var continue_button: Button
var workbench_button: Button

var story_panel: Panel
var joe_image: TextureRect
var fade_overlay: ColorRect


# ==========================================
# INITIALISATION
# ==========================================

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE

	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_build_interface()

	# Resume at the next Scientist when
	# saved progression already exists.

	var next_id: String = (
		SpacecraftGameState.get_next_scientist_id()
	)

	if next_id.is_empty():
		_show_final_launch()
	else:
		_start_encounter(next_id)


# ==========================================
# DRAW LAB CORRIDOR
# ==========================================

func _draw() -> void:
	draw_rect(
		Rect2(0, 0, 640, 360),
		BG
	)

	# Back wall
	draw_rect(
		Rect2(0, 40, 640, 188),
		Color("#b8d3d5")
	)

	# Ceiling
	draw_rect(
		Rect2(0, 38, 640, 17),
		Color("#718b98")
	)

	# Corridor floor
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 228),
			Vector2(640, 228),
			Vector2(640, 360),
			Vector2(0, 360)
		]),
		Color("#718c99")
	)

	# Floor tile lines
	for i in range(6):
		var x: float = float(i) * 130.0

		draw_line(
			Vector2(x, 228),
			Vector2(x - 80, 360),
			Color("#adc5cd"),
			1.0
		)

	for y in [255.0, 290.0, 330.0]:
		draw_line(
			Vector2(0, y),
			Vector2(640, y),
			Color("#adc5cd"),
			1.0
		)

	# Exit doorway
	draw_rect(
		Rect2(430, 75, 135, 153),
		Color("#536d7a")
	)

	draw_rect(
		Rect2(440, 84, 115, 144),
		Color("#253d51")
	)

	# Door warning lights
	draw_circle(
		Vector2(449, 97),
		4.0,
		Color("#7cdda7")
	)

	draw_circle(
		Vector2(547, 97),
		4.0,
		Color("#ffd077")
	)

	# Door text
	draw_rect(
		Rect2(467, 126, 58, 4),
		Color("#59d9e5")
	)

	draw_rect(
		Rect2(478, 137, 36, 3),
		Color("#59d9e5")
	)

	# Wall computers
	draw_rect(
		Rect2(83, 90, 100, 67),
		Color("#405968")
	)

	draw_rect(
		Rect2(90, 97, 86, 51),
		Color("#28566b")
	)

	draw_rect(
		Rect2(100, 108, 61, 3),
		Color("#75dfe1")
	)

	draw_rect(
		Rect2(100, 120, 40, 3),
		Color("#75dfe1")
	)

	draw_rect(
		Rect2(100, 132, 55, 3),
		Color("#75dfe1")
	)


# ==========================================
# UI HELPERS
# ==========================================

func _make_label(
	value: String,
	pos: Vector2,
	dimensions: Vector2,
	font_size: int,
	colour: Color
) -> Label:

	var result := Label.new()

	result.text = value
	result.position = pos
	result.size = dimensions

	result.add_theme_font_size_override(
		"font_size",
		font_size
	)

	result.add_theme_color_override(
		"font_color",
		colour
	)

	result.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	result.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(result)
	return result


func _make_button(
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
	normal.bg_color = Color("#176d87")
	normal.set_corner_radius_all(5)

	result.add_theme_stylebox_override(
		"normal",
		normal
	)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#2395ae")

	result.add_theme_stylebox_override(
		"hover",
		hover
	)

	add_child(result)
	return result


# ==========================================
# BUILD INTERFACE
# ==========================================

func _build_interface() -> void:

	title_label = _make_label(
		"SPACE VAULT // ESCAPE FROM EARTH",
		Vector2(14, 9),
		Vector2(615, 27),
		17,
		ACCENT
	)

	# Joe's illustration
	joe_image = TextureRect.new()

	joe_image.position = Vector2(194, 105)
	joe_image.size = Vector2(140, 120)

	joe_image.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)

	joe_image.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)

	joe_image.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	if ResourceLoader.exists(JOE_TEXTURE_PATH):
		joe_image.texture = (
			load(JOE_TEXTURE_PATH) as Texture2D
		)

	add_child(joe_image)

	story_panel = Panel.new()
	story_panel.position = Vector2(9, 244)
	story_panel.size = Vector2(622, 107)

	var style := StyleBoxFlat.new()

	style.bg_color = PANEL
	style.border_color = ACCENT
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)

	story_panel.add_theme_stylebox_override(
		"panel",
		style
	)

	add_child(story_panel)

	speaker_label = _make_label(
		"",
		Vector2(23, 254),
		Vector2(390, 20),
		12,
		ACCENT
	)

	dialogue_label = _make_label(
		"",
		Vector2(23, 277),
		Vector2(595, 37),
		11,
		LIGHT
	)

	status_label = _make_label(
		"",
		Vector2(24, 223),
		Vector2(595, 20),
		10,
		WARNING
	)

	continue_button = _make_button(
		"CONTINUE",
		Vector2(486, 318),
		Vector2(132, 26)
	)

	continue_button.pressed.connect(
		_next_dialogue
	)

	workbench_button = _make_button(
		"WORKBENCH",
		Vector2(349, 318),
		Vector2(129, 26)
	)

	workbench_button.pressed.connect(
		_open_workbench
	)

	workbench_button.hide()

	# The fade must remain above all scenes.
	fade_overlay = ColorRect.new()
	fade_overlay.position = Vector2.ZERO
	fade_overlay.size = SCREEN_SIZE
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(fade_overlay)


# ==========================================
# SHOW OR HIDE STORY
# ==========================================

func _show_story_ui(visible_value: bool) -> void:

	title_label.visible = visible_value
	speaker_label.visible = visible_value
	dialogue_label.visible = visible_value
	status_label.visible = visible_value

	continue_button.visible = visible_value
	story_panel.visible = visible_value
	joe_image.visible = visible_value

	if not visible_value:
		workbench_button.hide()


# ==========================================
# START SCIENTIST ENCOUNTER
# ==========================================

func _start_encounter(scientist_id: String) -> void:

	if not SCIENTISTS.has(scientist_id):
		return

	current_boss_id = scientist_id

	scene_mode = "intro"
	dialogue_index = 0

	dialogue_lines = (
		ENCOUNTERS.get(
			current_boss_id,
			[]
		)
	).duplicate(true)

	_show_story_ui(true)

	workbench_button.hide()

	status_label.text = (
		"ENCOUNTER // "
		+ str(
			SCIENTIST_NAMES.get(
				current_boss_id,
				"SCIENTIST"
			)
		)
	)

	continue_button.text = "CONTINUE"

	_display_dialogue()


# ==========================================
# DISPLAY DIALOGUE
# ==========================================

func _display_dialogue() -> void:

	if dialogue_index >= dialogue_lines.size():
		_complete_dialogue()
		return

	var line: Dictionary = dialogue_lines[
		dialogue_index
	]

	speaker_label.text = str(
		line.get("speaker", "")
	)

	dialogue_label.text = str(
		line.get("text", "")
	)

	if dialogue_index == dialogue_lines.size() - 1:

		if scene_mode == "intro":
			continue_button.text = "FIGHT"

		elif scene_mode == "victory":
			continue_button.text = "CONTINUE"

	else:
		continue_button.text = "NEXT"


func _next_dialogue() -> void:

	if busy:
		return

	dialogue_index += 1
	_display_dialogue()


func _complete_dialogue() -> void:

	if scene_mode == "intro":
		_start_battle()

	elif scene_mode == "victory":
		_continue_after_victory()

	elif scene_mode == "ending":
		_open_final_launch()


# ==========================================
# START SCIENTIST BATTLE
# ==========================================

func _start_battle() -> void:

	if not SpacecraftGameState.can_challenge_scientist(
		current_boss_id
	):
		status_label.text = "SCIENTIST LOCKED"
		return

	_show_story_ui(false)

	scene_mode = "battle"

	failed_simulations = 0
	last_turn = 1
	last_hp = 100

	battle = BATTLE_SCENE.instantiate()

	# Set the Scientist before _ready runs.
	battle.set("boss_id", current_boss_id)

	add_child(battle)

	battle.position = Vector2.ZERO

	battle.connect(
		"battle_won",
		Callable(self, "_on_battle_won")
	)

	fade_overlay.move_to_front()


# ==========================================
# DETECT LOSING SIMULATIONS
# ==========================================

func _process(_delta: float) -> void:

	if scene_mode != "battle":
		return

	if busy:
		return

	if not is_instance_valid(battle):
		return

	# The ScientistBattle script updates
	# turn_number after each resolved
	# simulation.
	#
	# A turn with no HP damage is considered
	# a failed engineering simulation.

	if bool(battle.get("busy")):
		return

	if bool(battle.get("battle_finished")):
		return

	var current_turn: int = int(
		battle.get("turn_number")
	)

	var current_hp: int = int(
		battle.get("boss_hp")
	)

	if current_turn <= last_turn:
		return

	if current_hp >= last_hp:
		failed_simulations += 1

		if failed_simulations >= MAX_FAILED_SIMULATIONS:
			_game_over()
			return

	last_turn = current_turn
	last_hp = current_hp


# ==========================================
# VICTORY
# ==========================================

func _on_battle_won(
	scientist_id: String
) -> void:

	if busy:
		return

	if scientist_id != current_boss_id:
		return

	# Existing battle handles component
	# unlocking and saved progression.
	# Verify it succeeded before continuing.

	if not SpacecraftGameState.has_defeated_scientist(
		scientist_id
	):
		push_warning(
			"Battle won, but progression was not recorded."
		)
		return

	busy = true

	await _fade_to_black(0.5)

	_clear_battle()

	scene_mode = "victory"
	dialogue_index = 0

	dialogue_lines = (
		VICTORY_DIALOGUE.get(
			current_boss_id,
			[]
		)
	).duplicate(true)

	_show_story_ui(true)

	status_label.text = (
		"VICTORY // THREE COMPONENTS UNLOCKED"
	)

	workbench_button.show()

	_display_dialogue()

	await _fade_from_black(0.5)

	busy = false


# ==========================================
# NEXT SCIENTIST
# ==========================================

func _continue_after_victory() -> void:

	if busy:
		return

	var next_id: String = (
		SpacecraftGameState.get_next_scientist_id()
	)

	if next_id.is_empty():
		_show_final_launch()
	else:
		_transition_to_encounter(next_id)


func _transition_to_encounter(
	next_id: String
) -> void:

	if busy:
		return

	busy = true

	await _fade_to_black(0.5)

	_start_encounter(next_id)

	await _fade_from_black(0.5)

	busy = false


# ==========================================
# GAME OVER
# ==========================================

func _game_over() -> void:

	if busy:
		return

	busy = true
	scene_mode = "game_over"

	await _fade_to_black(1.2)

	_clear_battle()

	# Remove all earned rewards, cleared
	# Scientist progress and equipped parts.
	# The six starter parts are restored.

	SpacecraftGameState.reset_progress()

	_show_story_ui(true)

	speaker_label.text = "GAME OVER"

	dialogue_label.text = (
		"Joe's spacecraft failed the engineering challenge."
	)

	status_label.text = (
		"MISSION FAILED // PROGRESSION RESET"
	)

	continue_button.hide()
	workbench_button.hide()

	await get_tree().create_timer(1.2).timeout

	# Restart from Dr. Niq.
	_start_encounter("niq")

	await _fade_from_black(1.1)

	busy = false


# ==========================================
# CLEAR CURRENT BATTLE
# ==========================================

func _clear_battle() -> void:

	if is_instance_valid(battle):
		battle.queue_free()

	battle = null


# ==========================================
# WORKBENCH BETWEEN SCIENTISTS
# ==========================================

func _open_workbench() -> void:

	if busy:
		return

	if is_instance_valid(builder):
		return

	builder = BUILDER_SCENE.instantiate()

	add_child(builder)

	builder.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if builder.has_signal("close_requested"):
		builder.connect(
			"close_requested",
			Callable(self, "_close_workbench")
		)

	fade_overlay.move_to_front()


func _close_workbench() -> void:

	if is_instance_valid(builder):
		builder.queue_free()

	builder = null


# ==========================================
# FINAL SCIENTIST DEFEATED
# ==========================================

func _show_final_launch() -> void:

	scene_mode = "ending"

	_show_story_ui(true)

	workbench_button.show()

	status_label.text = (
		"ALL SCIENTISTS DEFEATED"
	)

	dialogue_lines = [
		{
			"speaker": "NARRATOR",
			"text": "The laboratory falls silent. Joe has defeated every Scientist and recovered the spacecraft upgrades."
		},
		{
			"speaker": "JOE PENG",
			"text": "That's everyone. Time to finish the rocket and get out of here."
		},
		{
			"speaker": "MATCHA",
			"text": "Four Scientists defeated, sir. The escape facility awaits. Perhaps Earth will improve in our absence."
		}
	]

	dialogue_index = 0
	continue_button.text = "NEXT"

	_display_dialogue()


func _open_final_launch() -> void:

	if busy:
		return

	if not SpacecraftGameState.is_final_escape_unlocked():
		status_label.text = (
			"DEFEAT ALL SCIENTISTS FIRST"
		)
		return

	if not ResourceLoader.exists(
		LAUNCH_SCENE_PATH
	):
		status_label.text = (
			"LAUNCH SCENE NOT FOUND"
		)

		dialogue_label.text = (
			"Create EscapeLaunch.tscn before proceeding."
		)

		return

	get_tree().change_scene_to_file(
		LAUNCH_SCENE_PATH
	)


# ==========================================
# SCREEN FADE
# ==========================================

func _fade_to_black(
	duration: float
) -> void:

	fade_overlay.move_to_front()

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	var tween := create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		duration
	)

	await tween.finished


func _fade_from_black(
	duration: float
) -> void:

	fade_overlay.move_to_front()

	var tween := create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)
