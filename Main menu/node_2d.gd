extends Control

@export_file("*.tscn") var start_scene: String

@onready var start_button: Button = $VBoxContainer/Button

func _ready() -> void:
	start_button.grab_focus()
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "modulate:a", 0.45, 0.75)
	tween.tween_property(start_button, "modulate:a", 1.0, 0.75)

func _on_button_pressed() -> void:
	if start_scene != "":
		get_tree().change_scene_to_file(start_scene)
