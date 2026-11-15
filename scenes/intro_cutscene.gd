extends Node2D

@export_file("*.tscn") var scene_1_path: String = "res://scenes/scene1.tscn"
@export var dialogue_resource: DialogueResource

@onready var player: CharacterBody2D = $joe
@onready var spaceship: Node2D = $Spaceship
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

@onready var scientist_paths: Array[PathFollow2D] = [
	$Path_Ahmed/PathFollow2D,
	$Path_Niq/PathFollow2D,
	$Path_Gabby/PathFollow2D,
	$Path_Celine/PathFollow2D
]

@onready var scientists: Array[Node2D] = [
	$Path_Ahmed/PathFollow2D/ahmed,
	$Path_Niq/PathFollow2D/niq,
	$Path_Gabby/PathFollow2D/gabby,
	$Path_Celine/PathFollow2D/celine
]

func _ready() -> void:
	play_intro_cutscene()

func play_intro_cutscene() -> void:
	Global.is_cutscene_active = true
	spaceship.visible = true
	fade_rect.modulate.a = 0.0
	
	# Hide scientists and place them at the start of their paths
	for i in range(scientists.size()):
		scientists[i].visible = false
		scientist_paths[i].progress_ratio = 0.0
	
	# 1. Joe looks at his ship
	await get_tree().create_timer(0.8).timeout
	DialogueManager.show_dialogue_balloon(dialogue_resource, "intro_part1")
	await DialogueManager.dialogue_ended
	
	# 2. The 4 scientists walk downward along their Path2D routes
	var move_tween = create_tween().set_parallel(true)
	for i in range(scientists.size()):
		scientists[i].visible = true
		if scientists[i].has_node("AnimatedSprite2D"):
			scientists[i].get_node("AnimatedSprite2D").play("walk_down")
		move_tween.tween_property(scientist_paths[i], "progress_ratio", 1.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await move_tween.finished
	
	for sci in scientists:
		if sci.has_node("AnimatedSprite2D"):
			sci.get_node("AnimatedSprite2D").play("idle_down")
	
	# 3. Ahmed and Niq speak
	DialogueManager.show_dialogue_balloon(dialogue_resource, "intro_ambush")
	await DialogueManager.dialogue_ended
	
	# 4. Niq rushes Joe and knocks him out -> White hit flash + fade to black
	var niq = scientists[1]
	if niq.has_node("AnimatedSprite2D"):
		niq.get_node("AnimatedSprite2D").play("walk_down")
	var knockout_tween = create_tween()
	knockout_tween.tween_property(niq, "global_position", player.global_position + Vector2(12, 0), 0.25)
	await knockout_tween.finished
	
	fade_rect.color = Color.WHITE
	fade_rect.modulate.a = 0.85
	var flash_tween = create_tween()
	flash_tween.tween_property(fade_rect, "color", Color.BLACK, 0.2)
	flash_tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await flash_tween.finished
	
	# 5. Remove the rocket and hide the scientists while screen is black
	spaceship.visible = false
	for sci in scientists:
		sci.visible = false
	await get_tree().create_timer(1.2).timeout
	
	# 6. Fade back in as Joe wakes up
	var wake_tween = create_tween()
	wake_tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8)
	await wake_tween.finished
	
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").play("idle_down")
	
	DialogueManager.show_dialogue_balloon(dialogue_resource, "intro_wakeup")
	await DialogueManager.dialogue_ended
	
	# 7. Fade out and switch to playable Scene 1
	var transition_tween = create_tween()
	transition_tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await transition_tween.finished
	
	Global.is_cutscene_active = false
	get_tree().call_deferred("change_scene_to_file", scene_1_path)
