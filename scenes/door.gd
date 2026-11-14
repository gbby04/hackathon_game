extends Area2D
class_name Door

@export_file("*.tscn") var destination_level_log: String
@export var destination_door_tag: String
@export var spawn_direction: String = "left"

@onready var spawn: Marker2D = $Spawn

func _on_body_entered(body: Node2D) -> void:
	print("Entered door: ", body.name) # Check the Output panel at the bottom when testing!
	if body is CharacterBody2D:
		get_tree().call_deferred("change_scene_to_file", destination_level_log)
