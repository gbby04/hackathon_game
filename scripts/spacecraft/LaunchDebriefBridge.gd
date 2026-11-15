
extends Node

# ============================================================
# SPACE VAULT - INSTANT LAUNCH TRANSITION
# Godot 4.7
#
# Rocket finishes ascending
# -> Immediately fade to black
# -> Open Joe's cinematic escape dialogue
#
# No additional delays.
#
# Preserves:
# - Existing launch animation
# - Mission progression
# - NASA engineering calculations
# - Mission Results transition through EscapeDialogue
# ============================================================

signal launch_sequence_completed

const ESCAPE_DIALOGUE_SCENE: String = (
	"res://scenes/story/EscapeDialogue.tscn"
)

const FADE_DURATION: float = 0.4

var transition_started: bool = false
var fade_overlay: ColorRect


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	_create_fade_overlay()
	_connect_launch_signal()


# ============================================================
# CREATE BLACK FADE
# ============================================================

func _create_fade_overlay() -> void:
	var launch_root: Control = (
		get_parent() as Control
	)

	if launch_root == null:
		push_error(
			"LaunchDebriefBridge must be a child "
			+ "of the launch Control root."
		)
		return

	fade_overlay = ColorRect.new()
	fade_overlay.name = "LaunchFadeOverlay"
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	launch_root.add_child(fade_overlay)

	fade_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	fade_overlay.move_to_front()


# ============================================================
# CONNECT TO LAUNCH COMPLETION
# ============================================================

func _connect_launch_signal() -> void:
	var launch_root: Node = get_parent()

	if launch_root == null:
		return

	if not launch_root.has_signal(
		"launch_completed"
	):
		push_error(
			"Launch root is missing "
			+ "the launch_completed signal."
		)
		return

	var callback: Callable = Callable(
		self,
		"_on_launch_completed"
	)

	if not launch_root.is_connected(
		"launch_completed",
		callback
	):
		launch_root.connect(
			"launch_completed",
			callback
		)


# ============================================================
# ROCKET FINISHED ASCENDING
# ============================================================

func _on_launch_completed() -> void:
	complete_launch()


# ============================================================
# BEGIN INSTANT TRANSITION
# ============================================================

func complete_launch() -> void:
	if transition_started:
		return

	if not SpacecraftGameState.is_final_escape_unlocked():
		push_warning(
			"Cannot complete launch: "
			+ "Scientist progression incomplete."
		)
		return

	if not ResourceLoader.exists(
		ESCAPE_DIALOGUE_SCENE
	):
		push_error(
			"Missing cinematic escape scene: "
			+ ESCAPE_DIALOGUE_SCENE
		)
		return

	transition_started = true
	launch_sequence_completed.emit()

	# Start fading immediately after
	# the launch_completed signal.
	_fade_and_open_dialogue()


# ============================================================
# FADE TO BLACK, THEN OPEN JOE'S SCENE
# ============================================================

func _fade_and_open_dialogue() -> void:
	if not is_instance_valid(fade_overlay):
		push_error(
			"Launch fade overlay was not created."
		)
		return

	fade_overlay.move_to_front()

	fade_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	var tween: Tween = create_tween()

	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		FADE_DURATION
	)

	await tween.finished

	if not is_inside_tree():
		return

	var error: Error = (
		get_tree().change_scene_to_file(
			ESCAPE_DIALOGUE_SCENE
		)
	)

	if error != OK:
		push_error(
			"Failed to open EscapeDialogue: "
			+ str(error)
		)

		transition_started = false

		fade_overlay.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)


# ============================================================
# OPTIONAL TEST
# ============================================================

func test_results_transition() -> void:
	complete_launch()
