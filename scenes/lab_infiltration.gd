extends Node2D

const LAB_DIALOGUE: DialogueResource = preload("res://dialogues/lab_infiltration.dialogue")
const OUTSIDE_LAB_SCENE: String = "res://scenes/story/OutsideLab.tscn" # drag OutsideLab.tscn here from FileSystem if path differs

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	DialogueManager.show_dialogue_balloon(LAB_DIALOGUE, "start")
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(OUTSIDE_LAB_SCENE)
