
extends Control

# SPACE VAULT - SCIENTIST BATTLE
# Godot 4.7
#
# Visual improvements:
# - Light-coloured science laboratory background
# - White oval battle platforms
# - Larger Joe Peng, correctly positioned
# - Scientists retain existing animations
#
# Gameplay preserved:
# - Scientist challenge HP and per-boss engineering resource meters
# - Matcha dialogue
# - Readiness checks
# - Countermeasures
# - Engineering simulations
# - Turn-based battle
# - Ship Builder integration

signal battle_won(scientist_id: String)

@export_enum("niq", "gabby", "ahmed", "celine")
var boss_id: String = "niq"

const BUILDER_SCENE: PackedScene = preload(
    "res://scenes/spacecraft/ShipBuilder.tscn"
)

const AHMED_ANIMATION_PATH: String = (
    "res://scenes/battles/DrAhmedSprite.tscn"
)

const JOE_PATH: String = (
    "res://assets/battles/characters/joe_peng/joe_peng.png"
)

const SCIENTIST_PATHS: Dictionary = {
	"niq": "res://assets/battles/characters/scientists/dr_niq.png",
	"gabby": "res://assets/battles/characters/scientists/dr_gabby.png",
	"ahmed": "res://assets/battles/characters/scientists/dr_ahmed.png",
	"celine": "res://assets/battles/characters/scientists/dr_celine.png"
}

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

const INK: Color = Color("#30373a")
const LIGHT: Color = Color("#faf9ed")
const GREEN: Color = Color("#65b75b")

const BOSS_BAR_WIDTH: float = 157.0
const BATTERY_BAR_WIDTH: float = 104.0
const METER_HEIGHT: float = 8.0

const MAX_BOSS_HP: int = 100
const SIMULATION_DAMAGE: int = 40

const SCIENTIST_FRAME_COUNT: int = 4
const SCIENTIST_ANIMATION_FPS: float = 4.0

# Scientist remains on the upper-right platform.
const SCIENTIST_POSITION: Vector2 = Vector2(500, 114)
const SCIENTIST_SCALE: Vector2 = Vector2(3.0, 3.0)

# Joe's feet now align with the foreground platform.
# Larger than the previous 3.0 scale.
const JOE_POSITION: Vector2 = Vector2(120, 166)
const JOE_SCALE: Vector2 = Vector2(3.5, 3.5)

const REQUIRED_CATEGORIES: Array[String] = [
	"engine",
	"battery",
	"solar",
	"scanner",
	"communication",
    "fuel"
]


# ==========================================
# SCIENCE LABORATORY BACKGROUND
# ==========================================

class BattleArena:
	extends Control

	const WALL: Color = Color("#cbd9d9")
	const WALL_LIGHT: Color = Color("#e6eeee")
	const WALL_DARK: Color = Color("#9cb5b8")

	const FLOOR: Color = Color("#b9c8c7")
	const FLOOR_LIGHT: Color = Color("#d4dfdc")
	const FLOOR_LINE: Color = Color("#a3b7b6")

	const METAL: Color = Color("#829da6")
	const METAL_DARK: Color = Color("#526e7b")

	const SCREEN: Color = Color("#28576d")
	const SCREEN_LIGHT: Color = Color("#65c8cf")

	const PLATFORM: Color = Color("#ffffff")
	const PLATFORM_EDGE: Color = Color("#c7d5d1")

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()


	func _draw_oval(
		centre: Vector2,
		radius_x: float,
		radius_y: float,
		colour: Color
	) -> void:

		var points: PackedVector2Array = (
			PackedVector2Array()
		)

		for i in range(49):
			var angle: float = (
				float(i) / 48.0 * TAU
			)

			points.append(
				centre + Vector2(
					cos(angle) * radius_x,
					sin(angle) * radius_y
				)
			)

		draw_colored_polygon(points, colour)


	func _draw() -> void:

		# ----------------------------------
		# LABORATORY BACK WALL
		# ----------------------------------

		draw_rect(
			Rect2(0, 0, 640, 112),
			WALL
		)

		draw_rect(
			Rect2(0, 0, 640, 17),
			WALL_LIGHT
		)

		draw_rect(
			Rect2(0, 17, 640, 3),
			WALL_DARK
		)

		# Wall panel seams
		for i in range(9):
			var wall_x: float = float(i) * 80.0

			draw_line(
				Vector2(wall_x, 20),
				Vector2(wall_x, 105),
				Color("#b8cacc"),
				1.0
			)

		# ----------------------------------
		# LABORATORY WALL MONITORS
		# ----------------------------------

		# Central computer display
		draw_rect(
			Rect2(298, 28, 106, 64),
			METAL_DARK
		)

		draw_rect(
			Rect2(303, 33, 96, 52),
			SCREEN
		)

		draw_rect(
			Rect2(309, 40, 43, 3),
			SCREEN_LIGHT
		)

		draw_rect(
			Rect2(309, 49, 61, 2),
			Color("#4ba0ae")
		)

		draw_rect(
			Rect2(309, 58, 28, 2),
			SCREEN_LIGHT
		)

		draw_rect(
			Rect2(309, 66, 73, 2),
			Color("#4ba0ae")
		)

		# Green science graph
		draw_line(
			Vector2(356, 73),
			Vector2(364, 61),
			Color("#8ce6b7"),
			2.0
		)

		draw_line(
			Vector2(364, 61),
			Vector2(374, 69),
			Color("#8ce6b7"),
			2.0
		)

		draw_line(
			Vector2(374, 69),
			Vector2(388, 46),
			Color("#8ce6b7"),
			2.0
		)

		# Small wall terminal on right
		draw_rect(
			Rect2(559, 27, 64, 63),
			METAL_DARK
		)

		draw_rect(
			Rect2(565, 33, 52, 39),
			SCREEN
		)

		draw_rect(
			Rect2(572, 41, 37, 3),
			SCREEN_LIGHT
		)

		draw_rect(
			Rect2(572, 49, 23, 3),
			Color("#8ce6b7")
		)

		draw_rect(
			Rect2(572, 58, 32, 3),
			Color("#4ba0ae")
		)

		draw_circle(
			Vector2(572, 80),
			3,
			Color("#8ce6b7")
		)

		draw_circle(
			Vector2(583, 80),
			3,
			Color("#f3c770")
		)

		# ----------------------------------
		# LABORATORY FLOOR
		# ----------------------------------

		draw_rect(
			Rect2(0, 108, 640, 152),
			FLOOR
		)

		# Wall-to-floor skirting
		draw_rect(
			Rect2(0, 105, 640, 6),
			WALL_DARK
		)

		draw_rect(
			Rect2(0, 111, 640, 2),
			WALL_LIGHT
		)

		# Floor tile rows
		for row in range(4):
			var tile_y: float = (
				130.0 + float(row) * 38.0
			)

			draw_line(
				Vector2(0, tile_y),
				Vector2(640, tile_y),
				FLOOR_LINE,
				1.0
			)

		# Offset floor tiles
		for row in range(4):
			var offset_x: float = (
				0.0 if row % 2 == 0 else 40.0
			)

			for column in range(9):
				var tile_x: float = (
					float(column) * 80.0
					+ offset_x
				)

				draw_line(
					Vector2(tile_x, 113 + row * 38),
					Vector2(tile_x, 151 + row * 38),
					FLOOR_LINE,
					1.0
				)

		# Subtle light reflection on tiles
		draw_rect(
			Rect2(260, 119, 145, 8),
			Color("#d9e4e0", 0.45)
		)

		draw_rect(
			Rect2(440, 196, 138, 5),
			Color("#d9e4e0", 0.25)
		)

		# ----------------------------------
		# LAB EQUIPMENT AT LEFT BACK WALL
		# ----------------------------------

		# Partially visible storage cabinet
		draw_rect(
			Rect2(3, 94, 48, 72),
			METAL_DARK
		)

		draw_rect(
			Rect2(7, 99, 40, 62),
			METAL
		)

		draw_line(
			Vector2(27, 99),
			Vector2(27, 161),
			METAL_DARK,
			2.0
		)

		draw_rect(
			Rect2(19, 128, 4, 12),
			WALL_LIGHT
		)

		draw_rect(
			Rect2(31, 128, 4, 12),
			WALL_LIGHT
		)

		# ----------------------------------
		# LABORATORY BATTLE PLATFORMS
		# ----------------------------------

		# Scientist platform shadow
		_draw_oval(
			Vector2(500, 170),
			96,
			16,
			Color("#8dabad", 0.36)
		)

		# Scientist platform rim
		_draw_oval(
			Vector2(500, 167),
			93,
			15,
			PLATFORM_EDGE
		)

		# Scientist platform
		_draw_oval(
			Vector2(500, 164),
			90,
			12,
			PLATFORM
		)

		# Joe platform shadow
		_draw_oval(
			Vector2(120, 239),
			121,
			24,
			Color("#839d9e", 0.35)
		)

		# Joe platform rim
		_draw_oval(
			Vector2(120, 235),
			119,
			23,
			PLATFORM_EDGE
		)

		# Joe white platform
		_draw_oval(
			Vector2(120, 232),
			116,
			20,
			PLATFORM
		)


# ==========================================
# BATTLE STATE
# ==========================================

var boss: Dictionary = {}

var boss_hp: int = MAX_BOSS_HP
var turn_number: int = 1

var counter_active: bool = false
var busy: bool = false
var battle_finished: bool = false

var boss_fill: ColorRect
var battery_fill: ColorRect

var dialogue: Label
var battery_info: Label
var resource_label: Label
var battery_summary_label: Label
var boss_hp_label: Label

var inspect_button: Button
var counter_button: Button
var simulate_button: Button
var workbench_button: Button

var scientist_sprite: AnimatedSprite2D = null
var scientist_visual: CanvasItem = null
var joe_sprite: Sprite2D = null

var workbench: Control = null


# ==========================================
# INITIALISATION
# ==========================================

func _ready() -> void:
	custom_minimum_size = SCREEN_SIZE

	texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	boss = BossDatabase.get_boss(boss_id)

	if boss.is_empty():
		boss_id = "niq"
		boss = BossDatabase.get_boss(boss_id)

	_build_interface()
	_refresh_resource_info()
	_refresh_boss_hp()

	_matcha_says(
        "%s challenges you, sir!\n%s"
		% [
			str(boss.get("name", "Scientist")),
			str(boss.get(
				"challenge",
                "Engineering Challenge"
			))
		]
	)


# ==========================================
# UI HELPERS
# ==========================================

func _style(
	background_colour: Color,
	border_colour: Color = INK,
	border_width: int = 2
) -> StyleBoxFlat:

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background_colour
	style.border_color = border_colour

	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)

	return style


func _panel(
	at: Vector2,
	dimensions: Vector2,
	colour: Color
) -> Panel:

	var panel: Panel = Panel.new()
	panel.position = at
	panel.size = dimensions

	panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	panel.add_theme_stylebox_override(
		"panel",
		_style(colour)
	)

	add_child(panel)
	return panel


func _label(
	value: String,
	at: Vector2,
	dimensions: Vector2,
	font_size: int = 12,
	colour: Color = INK
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

	add_child(result)
	return result


func _button(
	value: String,
	at: Vector2
) -> Button:

	var button: Button = Button.new()
	button.text = value
	button.position = at
	button.size = Vector2(123, 36)

	button.add_theme_font_size_override(
		"font_size",
		11
	)

	for colour_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
        "font_focus_color"
	]:
		button.add_theme_color_override(
			colour_name,
			INK
		)

	button.add_theme_stylebox_override(
		"normal",
		_style(LIGHT)
	)

	button.add_theme_stylebox_override(
		"hover",
		_style(Color("#d8eecb"))
	)

	button.add_theme_stylebox_override(
		"pressed",
		_style(Color("#b8d9a8"))
	)

	button.add_theme_stylebox_override(
		"disabled",
		_style(Color("#ced4c8"))
	)

	button.add_theme_stylebox_override(
		"focus",
		StyleBoxEmpty.new()
	)

	add_child(button)
	return button


# ==========================================
# HP AND BATTERY METERS
# ==========================================

func _create_meter(
	at: Vector2,
	width_value: float,
	colour: Color
) -> ColorRect:

	var track: ColorRect = ColorRect.new()
	track.position = at
	track.size = Vector2(
		width_value,
		METER_HEIGHT
	)

	track.color = Color("#536158")
	track.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(track)

	var fill: ColorRect = ColorRect.new()
	fill.position = at
	fill.size = Vector2(
		width_value,
		METER_HEIGHT
	)

	fill.color = colour
	fill.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(fill)
	return fill


func _set_meter(
	fill: ColorRect,
	percentage: float,
	max_width: float
) -> void:

	var amount: float = clampf(
		percentage,
		0.0,
		100.0
	)

	fill.size.x = (
		max_width * amount / 100.0
	)

	if amount > 50.0:
		fill.color = GREEN
	elif amount > 20.0:
		fill.color = Color("#dcb94e")
	else:
		fill.color = Color("#d66c66")


func _animate_meter(
	fill: ColorRect,
	percentage: float,
	max_width: float
) -> void:

	var amount: float = clampf(
		percentage,
		0.0,
		100.0
	)

	var tween: Tween = create_tween()

	tween.tween_property(
		fill,
		"size:x",
		max_width * amount / 100.0,
		0.8
	)

	await tween.finished

	_set_meter(
		fill,
		amount,
		max_width
	)


# ==========================================
# JOE PENG - STATIC
# ==========================================

func _add_joe() -> void:

	if ResourceLoader.exists(JOE_PATH):
		var texture: Texture2D = (
			load(JOE_PATH) as Texture2D
		)

		if texture != null:
			joe_sprite = Sprite2D.new()

			joe_sprite.name = "JoePeng"
			joe_sprite.texture = texture
			joe_sprite.position = JOE_POSITION
			joe_sprite.scale = JOE_SCALE

			joe_sprite.texture_filter = (
				CanvasItem.TEXTURE_FILTER_NEAREST
			)

			add_child(joe_sprite)
			return

	_panel(
		Vector2(84, 155),
		Vector2(74, 78),
		Color("#8c91b8")
	)

	_label(
		"JOE",
		Vector2(95, 188),
		Vector2(48, 20),
		12,
		LIGHT
	)


# ==========================================
# SCIENTIST SPRITE ANIMATIONS
# ==========================================

func _create_animated_scientist(
	image_path: String
) -> AnimatedSprite2D:

	if not ResourceLoader.exists(image_path):
		return null

	var texture: Texture2D = (
		load(image_path) as Texture2D
	)

	if texture == null:
		return null

	if (
		texture.get_width() < 256
		or texture.get_height() < 64
	):
		push_warning(
            "Expected a 256x64 Scientist sprite sheet: "
			+ image_path
		)
		return null

	var frames: SpriteFrames = SpriteFrames.new()

	frames.add_animation("idle")
	frames.set_animation_speed(
		"idle",
		SCIENTIST_ANIMATION_FPS
	)

	frames.set_animation_loop("idle", true)

	for frame_index in range(
		SCIENTIST_FRAME_COUNT
	):
		var atlas_frame: AtlasTexture = (
			AtlasTexture.new()
		)

		atlas_frame.atlas = texture

		atlas_frame.region = Rect2(
			float(frame_index) * 64.0,
			0.0,
			64.0,
			64.0
		)

		frames.add_frame(
			"idle",
			atlas_frame
		)

	var animated: AnimatedSprite2D = (
		AnimatedSprite2D.new()
	)

	animated.name = "ScientistAnimated"
	animated.sprite_frames = frames
	animated.position = SCIENTIST_POSITION
	animated.scale = SCIENTIST_SCALE

	animated.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
	)

	return animated


func _add_scientist() -> void:

	# Keep Dr. Ahmed's existing animation scene.
	if (
		boss_id == "ahmed"
		and ResourceLoader.exists(
			AHMED_ANIMATION_PATH
		)
	):
		var packed_scene: PackedScene = (
			load(AHMED_ANIMATION_PATH) as PackedScene
		)

		if packed_scene != null:
			var instance: Node = (
				packed_scene.instantiate()
			)

			if instance is AnimatedSprite2D:
				scientist_sprite = (
					instance as AnimatedSprite2D
				)

				scientist_sprite.position = (
					SCIENTIST_POSITION
				)

				scientist_sprite.scale = (
					SCIENTIST_SCALE
				)

				scientist_sprite.texture_filter = (
					CanvasItem.TEXTURE_FILTER_NEAREST
				)

				add_child(scientist_sprite)
				scientist_visual = scientist_sprite

				if scientist_sprite.sprite_frames != null:
					if scientist_sprite.sprite_frames.has_animation(
                        "idle"
					):
						scientist_sprite.play("idle")

				return

			instance.free()

	var image_path: String = str(
		SCIENTIST_PATHS.get(boss_id, "")
	)

	scientist_sprite = (
		_create_animated_scientist(image_path)
	)

	if scientist_sprite != null:
		add_child(scientist_sprite)
		scientist_visual = scientist_sprite
		scientist_sprite.play("idle")
		return

	scientist_visual = _panel(
		Vector2(445, 97),
		Vector2(110, 75),
		Color("#a68cca")
	)

	_label(
		str(boss.get("name", "Scientist")),
		Vector2(449, 120),
		Vector2(102, 20),
		11,
		LIGHT
	)


# ==========================================
# BUILD BATTLE SCREEN
# ==========================================

func _build_interface() -> void:

	# Lab background with white platforms.
	var arena: BattleArena = BattleArena.new()
	arena.name = "BattleArena"
	arena.position = Vector2.ZERO
	arena.size = Vector2(640, 260)

	add_child(arena)

	# Scientist HP panel
	_panel(
		Vector2(17, 21),
		Vector2(250, 65),
		LIGHT
	)

	_label(
		str(boss.get("name", "Scientist")),
		Vector2(30, 31),
		Vector2(145, 20),
		15
	)

	boss_hp_label = _label(
		"100/100",
		Vector2(180, 34),
		Vector2(62, 17),
		10
	)

	boss_hp_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	_label(
		"HP",
		Vector2(37, 57),
		Vector2(24, 18),
		11
	)

	boss_fill = _create_meter(
		Vector2(71, 62),
		BOSS_BAR_WIDTH,
		GREEN
	)

	# Animated Scientist, upper-right
	_add_scientist()

	# Static Joe Peng, lower-left
	_add_joe()

	# Spacecraft engineering telemetry panel (not Joe HP)
	_panel(
		Vector2(358, 188),
		Vector2(250, 58),
		LIGHT
	)

	_label(
		"ENGINEERING",
		Vector2(372, 195),
		Vector2(127, 18),
		12
	)

	battery_summary_label = _label(
		"",
		Vector2(507, 195),
		Vector2(91, 18),
		9
	)
	battery_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	resource_label = _label(
		"",
		Vector2(372, 216),
		Vector2(38, 18),
		10
	)

	battery_fill = _create_meter(
		Vector2(412, 220),
		BATTERY_BAR_WIDTH,
		GREEN
	)

	battery_info = _label(
		"",
		Vector2(527, 215),
		Vector2(70, 18),
		10
	)

	# Dialogue interface
	_panel(
		Vector2(6, 259),
		Vector2(628, 95),
		Color("#ccd9c7")
	)

	_panel(
		Vector2(14, 267),
		Vector2(332, 78),
		LIGHT
	)

	dialogue = _label(
		"",
		Vector2(24, 277),
		Vector2(312, 58),
		12
	)

	# Battle buttons
	inspect_button = _button(
		"INSPECT",
		Vector2(359, 268)
	)

	counter_button = _button(
		"COUNTER",
		Vector2(493, 268)
	)

	simulate_button = _button(
		"SIMULATE",
		Vector2(359, 309)
	)

	workbench_button = _button(
		"WORKBENCH",
		Vector2(493, 309)
	)

	inspect_button.pressed.connect(_inspect)
	counter_button.pressed.connect(_counter)
	simulate_button.pressed.connect(_simulate)
	workbench_button.pressed.connect(_open_workbench)


# ==========================================
# DIALOGUE AND STATUS
# ==========================================

func _say(message: String) -> void:
	if is_instance_valid(dialogue):
		dialogue.text = message


func _matcha_says(message: String) -> void:
	_say("MATCHA: " + message)


# This bar represents the CURRENT BOSS'S engineering test, not Joe HP.
# Battery Wh is not interchangeable with mass, downlink or test pass rate.
func _refresh_resource_info() -> void:
	var stats: Dictionary = SpacecraftGameState.get_ship_stats()
	var test_label: String = ""
	var amount_text: String = ""
	var progress: float = 0.0

	match boss_id:
		"niq":
			test_label = "BAT"
			var available_wh: float = float(stats.get("battery_wh", 0.0))
			amount_text = "%.0f Wh" % available_wh
			progress = 100.0 if available_wh > 0.0 else 0.0
		"gabby":
			test_label = "MASS"
			var payload_kg: float = float(stats.get("mass_kg", 0.0)) + 50.0
			amount_text = "%.0f/500" % payload_kg
			# Remaining mass budget (more is safer).
			progress = clampf((500.0 - payload_kg) / 500.0 * 100.0, 0.0, 100.0)
		"ahmed":
			test_label = "DATA"
			var downlink: float = float(stats.get("downlink_mb_per_min", 0.0))
			var science: float = float(stats.get("science_data_mb_per_min", 0.0))
			var deliverable: float = minf(science * 20.0, downlink * 3.0)
			amount_text = "%.0f/15 MB" % deliverable
			progress = clampf(deliverable / 15.0 * 100.0, 0.0, 100.0)
		"celine":
			test_label = "SYS"
			amount_text = "3 CHECKS"
			progress = 0.0

	resource_label.text = test_label
	battery_summary_label.text = "BAT %.0f Wh" % float(stats.get("battery_wh", 0.0))
	battery_info.text = amount_text
	_set_meter(battery_fill, progress, BATTERY_BAR_WIDTH)


# Update telemetry from the same MissionSimulation result used for victory.
func _show_simulation_telemetry(result: Dictionary) -> void:
	var progress: float = 0.0
	var amount_text: String = ""

	match boss_id:
		"niq":
			resource_label.text = "BAT"
			var remaining_wh: float = maxf(float(result.get("battery_remaining_wh", 0.0)), 0.0)
			amount_text = "%.1f Wh" % remaining_wh
			progress = float(result.get("battery_percentage", 0.0))
		"gabby":
			resource_label.text = "MASS"
			var mass_kg: float = float(result.get("mass_kg", 0.0))
			var limit_kg: float = float(result.get("mass_limit_kg", 500.0))
			amount_text = "%.0f/%.0f" % [mass_kg, limit_kg]
			if limit_kg > 0.0:
				progress = clampf((limit_kg - mass_kg) / limit_kg * 100.0, 0.0, 100.0)
		"ahmed":
			resource_label.text = "DATA"
			var delivered: float = float(result.get("transmitted_data_mb", 0.0))
			var required: float = float(result.get("required_data_mb", 15.0))
			amount_text = "%.0f/%.0f MB" % [delivered, required]
			if required > 0.0:
				progress = clampf(delivered / required * 100.0, 0.0, 100.0)
		"celine":
			resource_label.text = "SYS"
			var passed_count: int = 0
			for key in ["power", "launch", "communications"]:
				var check: Dictionary = result.get(key, {})
				if bool(check.get("success", false)):
					passed_count += 1
			amount_text = "%d/3 OK" % passed_count
			progress = float(passed_count) / 3.0 * 100.0

	await _animate_meter(battery_fill, progress, BATTERY_BAR_WIDTH)
	battery_info.text = amount_text
	var built_stats: Dictionary = SpacecraftGameState.get_ship_stats()
	var battery_wh: float = float(built_stats.get("battery_wh", 0.0))
	if boss_id == "niq":
		battery_wh = maxf(float(result.get("battery_remaining_wh", 0.0)), 0.0)
	elif boss_id == "celine":
		var power_check: Dictionary = result.get("power", {})
		battery_wh = maxf(float(power_check.get("battery_remaining_wh", battery_wh)), 0.0)
	battery_summary_label.text = "BAT %.0f Wh" % battery_wh
	if not bool(result.get("success", false)):
		battery_fill.color = Color("#d66c66")


func _refresh_boss_hp() -> void:
	boss_hp_label.text = (
		"%d/%d" % [boss_hp, MAX_BOSS_HP]
	)


# ==========================================
# EQUIPMENT READINESS
# ==========================================

func _has_equipped(category: String) -> bool:
	var equipped_id: String = str(
		SpacecraftGameState.get_equipped_component(
			category
		)
	)

	return not equipped_id.is_empty()


func _readiness_check() -> Dictionary:
	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	var missing: Array[String] = []

	match boss_id:
		"niq":
			if not _has_equipped("battery"):
				missing.append("Battery")

			if float(stats.get("power_w", 0.0)) <= 0.0:
				missing.append("Powered equipment")

		"gabby":
			if not _has_equipped("engine"):
				missing.append("Engine")

			if not _has_equipped("fuel"):
				missing.append("Fuel tank")

		"ahmed":
			if not _has_equipped("scanner"):
				missing.append("Science scanner")

			if not _has_equipped("communication"):
				missing.append("Communication module")

		"celine":
			for category in REQUIRED_CATEGORIES:
				if not _has_equipped(category):
					missing.append(
						_category_display_name(category)
					)

	if not missing.is_empty():
		return {
			"ready": false,
			"missing": missing,
			"message": (
                "Missing: %s, sir.\nThe WORKBENCH is our next stop."
				% ", ".join(missing)
			)
		}

	return {
		"ready": true,
		"missing": [],
		"message": (
            "Required equipment installed, sir.\n"
			+ "The simulation will determine if it is sufficient."
		)
	}


func _category_display_name(
	category: String
) -> String:

	match category:
		"engine":
			return "Engine"
		"battery":
			return "Battery"
		"solar":
			return "Solar panel"
		"scanner":
			return "Science scanner"
		"communication":
			return "Communication module"
		"fuel":
			return "Fuel tank"

	return category


func _inspect() -> void:
	if busy:
		return

	if battle_finished:
		_matcha_says(
            "Challenge complete, sir. An excellent result."
		)
		return

	var readiness: Dictionary = (
		_readiness_check()
	)

	if not bool(readiness.get("ready", false)):
		_matcha_says(str(readiness.get("message", "")))
		return

	var result: Dictionary = _evaluate_boss()
	_matcha_says(str(result.get("explanation", "Simulation unavailable.")))


# ==========================================
# COUNTERMEASURES
# ==========================================

func _counter() -> void:
	if busy or battle_finished:
		return

	counter_active = not counter_active

	if not counter_active:
		counter_button.text = "COUNTER"
		_matcha_says("Countermeasure offline, sir. We can restore it if required.")
		return

	counter_button.text = "ACTIVE"

	match boss_id:
		"niq":
			_matcha_says(
                "Power saving engaged, sir.\n"
				+ "Thirty watts less to worry about."
			)

		"gabby":
			_matcha_says(
                "Test payload jettisoned, sir.\n"
				+ "Gravity will be disappointed."
			)

		"ahmed":
			_matcha_says(
                "Signal recovery online, sir.\n"
				+ "Six minutes of contact restored."
			)

		"celine":
			_matcha_says(
                "System stabilisation active, sir.\n"
				+ "Power reduced by thirty watts."
			)


# ==========================================
# ENGINEERING SIMULATIONS
# ==========================================

func _evaluate_boss() -> Dictionary:
	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	).duplicate(true)

	var simulation: MissionSimulation = (
		SpacecraftGameState.simulator
	)

	var pressure: int = mini(
		turn_number - 1,
		2
	)

	match boss_id:
		"niq":
			var eclipse_minutes: float = (
				35.0 + float(pressure) * 5.0
			)

			if counter_active:
				stats["power_w"] = maxf(
					float(stats.get("power_w", 0.0))
					- 30.0,
					0.0
				)

			return simulation.check_eclipse(
				stats,
				eclipse_minutes
			)

		"gabby":
			var extra_mass: float = (
				50.0 + float(pressure) * 15.0
			)

			if counter_active:
				extra_mass = 0.0

			stats["mass_kg"] = (
				float(stats.get("mass_kg", 0.0))
				+ extra_mass
			)

			return simulation.check_launch(
				stats,
				500.0
			)

		"ahmed":
			var contact_minutes: float = (
				3.0 - float(pressure) * 0.5
			)

			if counter_active:
				contact_minutes = 6.0

			return simulation.check_communications(
				stats,
				20.0,
				contact_minutes,
				15.0
			)

		"celine":
			var final_eclipse: float = (
				35.0 + float(pressure) * 5.0
			)

			if counter_active:
				stats["power_w"] = maxf(
					float(stats.get("power_w", 0.0))
					- 30.0,
					0.0
				)

			stats["mass_kg"] = (
				float(stats.get("mass_kg", 0.0))
				+ 50.0
				+ float(pressure) * 15.0
			)

			var power: Dictionary = (
				simulation.check_eclipse(
					stats,
					final_eclipse
				)
			)

			var launch: Dictionary = (
				simulation.check_launch(
					stats,
					500.0
				)
			)

			var communications: Dictionary = (
				simulation.check_communications(
					stats,
					20.0,
					3.0 - float(pressure) * 0.5,
					15.0
				)
			)

			var valid: bool = (
				bool(power.get("valid", false))
				and bool(launch.get("valid", false))
				and bool(
					communications.get("valid", false)
				)
			)

			var success: bool = (
				bool(power.get("success", false))
				and bool(launch.get("success", false))
				and bool(
					communications.get("success", false)
				)
			)

			return {
				"valid": valid,
				"success": success,
				"explanation": (
                    "All engineering checks passed!"
					if success
					else "One or more systems failed."
				),
				"power": power,
				"launch": launch,
				"communications": communications
			}

	return {
		"valid": false,
		"success": false,
		"explanation": "Unknown Scientist."
	}


# ==========================================
# TURN-BASED BATTLE
# ==========================================

func _simulate() -> void:
	if busy or battle_finished:
		return

	var readiness: Dictionary = (
		_readiness_check()
	)

	if not bool(readiness.get("ready", false)):
		_matcha_says(
			str(readiness.get(
				"message",
                "The rocket is not ready, sir."
			))
		)
		return

	busy = true
	_set_buttons(false)

	_say(
        "TURN %d\n%s used %s!"
		% [
			turn_number,
			str(boss.get("name", "Scientist")),
			str(boss.get("attack", "CHALLENGE"))
		]
	)

	if is_instance_valid(scientist_visual):
		var original_colour: Color = (
			scientist_visual.modulate
		)

		var attack: Tween = create_tween()

		attack.tween_property(
			scientist_visual,
			"modulate",
			Color("#ffaaaa"),
			0.15
		)

		attack.tween_property(
			scientist_visual,
			"modulate",
			original_colour,
			0.15
		)

		await attack.finished

	await get_tree().create_timer(0.45).timeout

	var result: Dictionary = _evaluate_boss()

	if not bool(result.get("valid", false)):
		_matcha_says(
			str(result.get(
				"explanation",
                "Simulation unavailable, sir."
			))
		)

		busy = false
		_set_buttons(true)
		return

	var passed: bool = bool(
		result.get("success", false)
	)

	await _show_simulation_telemetry(result)

	if passed:
		boss_hp = maxi(
			boss_hp - SIMULATION_DAMAGE,
			0
		)

		var hp_percentage: float = (
			float(boss_hp)
			/ float(MAX_BOSS_HP)
			* 100.0
		)

		await _animate_meter(
			boss_fill,
			hp_percentage,
			BOSS_BAR_WIDTH
		)

		_refresh_boss_hp()

		if boss_hp <= 0:
			_finish_battle()
			return

		_matcha_says(
			(
                "Test passed, sir. %d damage dealt.\n"
				+ "Our opponent appears less enthusiastic."
			) % SIMULATION_DAMAGE
		)

	else:
		_matcha_says(
            "Test failed, sir.\n%s"
			% str(result.get(
				"explanation",
                "Upgrade the spacecraft."
			))
		)

	turn_number += 1
	busy = false
	_set_buttons(true)


# ==========================================
# VICTORY
# ==========================================

func _finish_battle() -> void:
	battle_finished = true
	busy = false

	_matcha_says(
		(
            "%s defeated, sir!\n"
			+ "An impressive result for stolen equipment."
		) % str(boss.get("name", "Scientist"))
	)

	if is_instance_valid(scientist_sprite):
		scientist_sprite.stop()

	_set_buttons(false)

	inspect_button.disabled = false
	workbench_button.disabled = false

	battle_won.emit(boss_id)


func _set_buttons(enabled: bool) -> void:
	inspect_button.disabled = not enabled
	counter_button.disabled = not enabled
	simulate_button.disabled = not enabled
	workbench_button.disabled = not enabled


# ==========================================
# SHIP BUILDER
# ==========================================

func _open_workbench() -> void:
	if busy or is_instance_valid(workbench):
		return

	workbench = BUILDER_SCENE.instantiate()
	add_child(workbench)

	workbench.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if workbench.has_signal("close_requested"):
		workbench.connect(
			"close_requested",
			Callable(self, "_close_workbench")
		)


func _close_workbench() -> void:
	if is_instance_valid(workbench):
		workbench.queue_free()
		workbench = null

	_refresh_resource_info()

	if battle_finished:
		_matcha_says(
            "%s is defeated, sir.\nWe may proceed."
			% str(boss.get("name", "Scientist"))
		)
		return

	counter_active = false
	counter_button.text = "COUNTER"

	_set_buttons(true)

	var readiness: Dictionary = (
		_readiness_check()
	)

	_matcha_says(
		str(readiness.get("message", ""))
	)
