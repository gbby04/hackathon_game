
extends Control

# SPACE VAULT - B-MO SHIP BUILDER
# Step 7 - Shared State Integration
# Godot 4.7

const BG_COLOR = Color("#101827")
const PANEL_COLOR = Color("#1d293b")
const BUTTON_COLOR = Color("#304157")
const SELECTED_COLOR = Color("#155e75")
const TEXT_COLOR = Color("#edf6ff")
const MUTED_COLOR = Color("#a6bad3")
const ACCENT_COLOR = Color("#67e8f9")
const SUCCESS_COLOR = Color("#86efac")
const WARNING_COLOR = Color("#fbbf24")

const CATEGORIES = [
	"engine",
	"battery",
	"solar",
	"scanner",
	"communication",
    "fuel"
]

const CATEGORY_NAMES = {
	"engine": "Engine",
	"battery": "Battery",
	"solar": "Solar Panel",
	"scanner": "Science Scanner",
	"communication": "Communication",
	"fuel": "Fuel Tank"
}

var selected_category: String = "engine"

var category_list: VBoxContainer
var component_list: VBoxContainer
var stats_list: VBoxContainer
var message_label: Label


func _ready() -> void:
	if not SpacecraftGameState.spacecraft.database.loaded:
		push_error("Component database could not load.")
		return

	_build_interface()
	_refresh_all()

	SpacecraftGameState.equipment_changed.connect(
		_on_spacecraft_updated
	)

	SpacecraftGameState.inventory_changed.connect(
		_on_inventory_updated
	)

	_check_engineering_warnings()


func _build_interface() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var background: ColorRect = ColorRect.new()
	background.color = BG_COLOR
	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left", 10
	)
	margin.add_theme_constant_override(
		"margin_right", 10
	)
	margin.add_theme_constant_override(
		"margin_top", 8
	)
	margin.add_theme_constant_override(
		"margin_bottom", 8
	)
	add_child(margin)

	var main_layout: VBoxContainer = VBoxContainer.new()
	main_layout.add_theme_constant_override(
		"separation", 8
	)
	margin.add_child(main_layout)

	# HEADER
	var header: HBoxContainer = HBoxContainer.new()
	main_layout.add_child(header)

	var title: Label = _make_label(
		"B-MO  //  SHIP BUILDER",
		20,
		ACCENT_COLOR
	)
	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	header.add_child(title)

	var online_label: Label = _make_label(
		"SYSTEM ONLINE",
		12,
		SUCCESS_COLOR
	)
	header.add_child(online_label)

	# THREE MAIN PANELS
	var content: HBoxContainer = HBoxContainer.new()
	content.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	content.add_theme_constant_override(
		"separation", 8
	)
	main_layout.add_child(content)

	# LEFT - CATEGORIES
	var category_panel: VBoxContainer = _create_panel(
		content,
		"COMPONENTS",
		165
	)

	var category_scroll: ScrollContainer = (
		ScrollContainer.new()
	)
	category_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	category_panel.add_child(category_scroll)

	category_list = VBoxContainer.new()
	category_list.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	category_list.add_theme_constant_override(
		"separation", 5
	)
	category_scroll.add_child(category_list)

	# MIDDLE - AVAILABLE PARTS
	var parts_panel: VBoxContainer = _create_panel(
		content,
		"AVAILABLE PARTS",
		210
	)

	var parts_scroll: ScrollContainer = (
		ScrollContainer.new()
	)
	parts_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	parts_panel.add_child(parts_scroll)

	component_list = VBoxContainer.new()
	component_list.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	component_list.add_theme_constant_override(
		"separation", 6
	)
	parts_scroll.add_child(component_list)

	# RIGHT - SHIP STATS
	var stats_panel: VBoxContainer = _create_panel(
		content,
		"SHIP STATISTICS",
		210
	)

	var stats_scroll: ScrollContainer = (
		ScrollContainer.new()
	)
	stats_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	stats_panel.add_child(stats_scroll)

	stats_list = VBoxContainer.new()
	stats_list.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	stats_list.add_theme_constant_override(
		"separation", 4
	)
	stats_scroll.add_child(stats_list)

	# BOTTOM STATUS PANEL
	var status_panel: PanelContainer = (
		PanelContainer.new()
	)
	status_panel.add_theme_stylebox_override(
		"panel",
		_make_style(Color("#153e52"))
	)
	main_layout.add_child(status_panel)

	var status_margin: MarginContainer = (
		MarginContainer.new()
	)
	status_margin.add_theme_constant_override(
		"margin_left", 10
	)
	status_margin.add_theme_constant_override(
		"margin_right", 10
	)
	status_margin.add_theme_constant_override(
		"margin_top", 6
	)
	status_margin.add_theme_constant_override(
		"margin_bottom", 6
	)
	status_panel.add_child(status_margin)

	message_label = _make_label(
		"B-MO: Systems ready.",
		12,
		TEXT_COLOR
	)
	message_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	status_margin.add_child(message_label)


func _create_panel(
	parent: Control,
	heading: String,
	panel_width: float
) -> VBoxContainer:

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size.x = panel_width
	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	panel.add_theme_stylebox_override(
		"panel",
		_make_style(PANEL_COLOR)
	)
	parent.add_child(panel)

	var outer_margin: MarginContainer = (
		MarginContainer.new()
	)
	outer_margin.add_theme_constant_override(
		"margin_left", 8
	)
	outer_margin.add_theme_constant_override(
		"margin_right", 8
	)
	outer_margin.add_theme_constant_override(
		"margin_top", 8
	)
	outer_margin.add_theme_constant_override(
		"margin_bottom", 8
	)
	panel.add_child(outer_margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override(
		"separation", 8
	)
	outer_margin.add_child(layout)

	layout.add_child(
		_make_label(heading, 12, ACCENT_COLOR)
	)

	return layout


func _make_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(5)
	return style


func _make_label(
	value: String,
	font_size: int = 13,
	font_color: Color = TEXT_COLOR
) -> Label:

	var label: Label = Label.new()
	label.text = value
	label.add_theme_color_override(
		"font_color",
		font_color
	)
	label.add_theme_font_size_override(
		"font_size",
		font_size
	)
	return label


func _make_button(
	value: String,
	selected: bool = false
) -> Button:

	var button: Button = Button.new()
	button.text = value
	button.custom_minimum_size.y = 30

	button.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)

	var normal_color: Color = BUTTON_COLOR

	if selected:
		normal_color = SELECTED_COLOR

	button.add_theme_stylebox_override(
		"normal",
		_make_style(normal_color)
	)
	button.add_theme_stylebox_override(
		"hover",
		_make_style(Color("#176783"))
	)
	button.add_theme_stylebox_override(
		"pressed",
		_make_style(Color("#0e7490"))
	)

	return button


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _refresh_all() -> void:
	_refresh_categories()
	_refresh_components()
	_refresh_stats()


func _refresh_categories() -> void:
	_clear_container(category_list)

	for category in CATEGORIES:
		var category_id: String = str(category)
		var display_name: String = str(
			CATEGORY_NAMES[category_id]
		)
		var is_selected: bool = (
			category_id == selected_category
		)

		var button: Button = _make_button(
			display_name,
			is_selected
		)
		category_list.add_child(button)
		button.pressed.connect(
			_on_category_selected.bind(category_id)
		)


func _refresh_components() -> void:
	_clear_container(component_list)

	var components: Array = (
		SpacecraftGameState.get_available_components(
			selected_category
		)
	)

	var equipped: Dictionary = (
		SpacecraftGameState.get_equipped_component(
			selected_category
		)
	)

	var equipped_name: String = str(
		equipped.get("name", "None")
	)

	var equipped_label: Label = _make_label(
		"EQUIPPED: " + equipped_name,
		11,
		SUCCESS_COLOR
	)
	equipped_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	component_list.add_child(equipped_label)

	if components.is_empty():
		component_list.add_child(
			_make_label("No unlocked parts.", 11)
		)
		return

	for item in components:
		var component: Dictionary = item

		var component_id: String = str(
			component.get("id", "")
		)
		var component_name: String = str(
			component.get("name", "Unknown")
		)

		var is_equipped: bool = (
			component_id == str(
				equipped.get("id", "")
			)
		)

		var button_text: String = component_name

		if is_equipped:
			button_text += " [EQUIPPED]"

		var button: Button = _make_button(
			button_text,
			is_equipped
		)
		button.add_theme_font_size_override(
			"font_size", 11
		)
		component_list.add_child(button)

		button.pressed.connect(
			_on_component_selected.bind(
				component_id
			)
		)

		var details: String = (
            "Mass: %.0f kg | Power: %.0f W\n"
			+ "Cost: %.0f credits"
		) % [
			float(component.get("mass_kg", 0)),
			float(component.get("power_w", 0)),
			float(component.get("cost_credits", 0))
		]

		component_list.add_child(
			_make_label(details, 11, MUTED_COLOR)
		)


func _refresh_stats() -> void:
	_clear_container(stats_list)

	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	_add_stat(
		"TOTAL MASS",
		"%.1f kg" % float(stats["mass_kg"])
	)
	_add_stat(
		"POWER CONSUMPTION",
		"%.1f W" % float(stats["power_w"])
	)
	_add_stat(
		"BATTERY CAPACITY",
		"%.1f Wh" % float(stats["battery_wh"])
	)
	_add_stat(
		"SOLAR GENERATION",
		"%.1f W" % float(stats["solar_generation_w"])
	)
	_add_stat(
		"TOTAL COST",
		"%.0f credits" % float(stats["cost_credits"])
	)
	_add_stat(
		"BUDGET REMAINING",
		"%.0f" % float(stats["budget_remaining"])
	)
	_add_stat(
		"SCIENCE SCORE",
		"%.0f" % float(stats["science_score"])
	)
	_add_stat(
		"ENGINE THRUST",
		"%.1f kN" % float(stats["thrust_kn"])
	)
	_add_stat(
		"DOWNLINK",
		"%.1f MB/min" % float(
			stats["downlink_mb_per_min"]
		)
	)


func _add_stat(
	stat_name: String,
	stat_value: String
) -> void:

	var row: HBoxContainer = HBoxContainer.new()
	stats_list.add_child(row)

	var name_label: Label = _make_label(
		stat_name,
		10,
		MUTED_COLOR
	)
	name_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	row.add_child(name_label)

	var value_label: Label = _make_label(
		stat_value,
		11,
		TEXT_COLOR
	)
	row.add_child(value_label)


func _on_category_selected(category: String) -> void:
	selected_category = category
	_refresh_categories()
	_refresh_components()

	message_label.text = (
        "B-MO: Viewing "
		+ str(CATEGORY_NAMES[category])
		+ " components."
	)


func _on_component_selected(component_id: String) -> void:
	var component: Dictionary = (
		SpacecraftGameState.spacecraft.database.get_component(
			component_id
		)
	)

	if component.is_empty():
		return

	var success: bool = (
		SpacecraftGameState.equip_component(
			component_id
		)
	)

	if not success:
		message_label.text = (
            "B-MO: This component is locked "
			+ "or cannot be equipped."
		)
		return

	_refresh_components()
	_check_engineering_warnings()


func _on_spacecraft_updated(_stats: Dictionary) -> void:
	_refresh_stats()


func _on_inventory_updated() -> void:
	_refresh_components()


func _check_engineering_warnings() -> void:
	var stats: Dictionary = (
		SpacecraftGameState.get_ship_stats()
	)

	if not bool(stats["within_budget"]):
		message_label.text = (
            "B-MO WARNING: Build exceeds the budget!"
		)
		return

	var eclipse_result: Dictionary = (
		SpacecraftGameState.check_eclipse(35.0)
	)

	if not bool(eclipse_result.get("success", false)):
		message_label.text = (
            "B-MO WARNING: Insufficient battery "
			+ "energy for the eclipse!"
		)
		return

	var launch_result: Dictionary = (
		SpacecraftGameState.check_launch(500.0)
	)

	if not bool(launch_result.get("success", false)):
		message_label.text = (
            "B-MO WARNING: Launch requirements "
			+ "are not satisfied!"
		)
		return

	message_label.text = (
        "B-MO: Ship configuration updated. "
		+ "Basic engineering checks passed."
	)
