extends Area2D
class_name Door

@export_file("*.tscn") var destination_level_log: String
@export var destination_door_tag: String
@export var spawn_direction: String = "left"

# Assign your scene1.dialogue file in the Inspector
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "path_locked"

@onready var spawn: Marker2D = $Spawn

var is_pushing_back: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player") and not is_pushing_back:
		if Global.found_matcha:
			# Matcha was found! Transition to Scene 2
			get_tree().call_deferred("change_scene_to_file", destination_level_log)
		else:
			# Matcha hasn't been found yet! Lock the player in place and show dialogue
			is_pushing_back = true
			
			if dialogue_resource:
				DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
				await DialogueManager.dialogue_ended
			
			# Push the player back to the left (out of the Door trigger zone)
			var push_target = body.global_position + Vector2(-24, 0)
			var tween = create_tween()
			tween.tween_property(body, "global_position", push_target, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
			
			is_pushing_back = false
