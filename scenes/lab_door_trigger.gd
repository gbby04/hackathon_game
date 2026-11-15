extends Area2D

const LAB_INFILTRATION_SCENE: String = "res://scenes/lab_infiltration.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("TRIGGERED BY: ", body.name)
	if body.is_in_group("player") or body.name.to_lower() == "joe":
		get_tree().call_deferred("change_scene_to_file", LAB_INFILTRATION_SCENE)
