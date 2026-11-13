
extends Control

# SPACE VAULT - TEAM INTEGRATION TEST
# Godot 4.7 - Member 2

const BUILDER_SCENE = preload(
    "res://scenes/spacecraft/ShipBuilder.tscn"
)

var ship_builder: Control = null
var close_button: Button = null
var status_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 12)
	add_child(layout)

	var title: Label = Label.new()
	title.text = "SPACE VAULT - INTEGRATION TEST"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status_label)

	var builder_button: Button = Button.new()
	builder_button.text = "OPEN SHIP BUILDER"
	layout.add_child(builder_button)
	builder_button.pressed.connect(_open_ship_builder)

	var watt_button: Button = Button.new()
	watt_button.text = "TEST DR. WATT"
	layout.add_child(watt_button)
	watt_button.pressed.connect(_test_dr_watt)

	_refresh_status()


func _open_ship_builder() -> void:
	if is_instance_valid(ship_builder):
		return

	ship_builder = BUILDER_SCENE.instantiate()
	add_child(ship_builder)

	ship_builder.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Create a visible close button above the builder.
	close_button = Button.new()
	close_button.text = "BACK TO TEST MENU"
	close_button.custom_minimum_size = Vector2(155, 32)

	close_button.set_anchors_preset(
		Control.PRESET_TOP_RIGHT
	)

	close_button.offset_left = -165
	close_button.offset_top = 4
	close_button.offset_right = -10
	close_button.offset_bottom = 36

	close_button.add_theme_font_size_override(
		"font_size", 11
	)

	add_child(close_button)

	# Keep the button above the Ship Builder.
	close_button.move_to_front()

	close_button.pressed.connect(
		_close_ship_builder
	)

	print("Ship Builder opened.")


func _input(event: InputEvent) -> void:
	if not is_instance_valid(ship_builder):
		return

	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_ESCAPE
	):
		_close_ship_builder()
		get_viewport().set_input_as_handled()


func _close_ship_builder() -> void:
	if is_instance_valid(close_button):
		close_button.queue_free()
		close_button = null

	if is_instance_valid(ship_builder):
		ship_builder.queue_free()
		ship_builder = null

	_refresh_status()

	print("Returned from Ship Builder.")
	print("Shared spacecraft configuration preserved.")


func _refresh_status() -> void:
	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	status_label.text = (
        "Mass: %.1f kg | Battery: %.1f Wh | Power: %.1f W"
	) % [
		float(stats["mass_kg"]),
		float(stats["battery_wh"]),
		float(stats["power_w"])
	]


func _test_dr_watt() -> void:
	var result: Dictionary = (
		SpacecraftGameState.check_eclipse(35.0)
	)

	print("")
	print("===================================")
	print("DR. WATT - ECLIPSE TEST")
	print("===================================")

	print("Energy needed: ", result["energy_needed_wh"], " Wh")
	print("Battery remaining: ", result["remaining_wh"], " Wh")
	print("Success: ", result["success"])
	print(result["explanation"])

	status_label.text = str(
		result["explanation"]
	)
