extends Area2D

@export var matcha_scene: PackedScene
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "rubble_matcha"

@onready var spawn_point: Marker2D = $SpawnPoint

var player_in_range: bool = false
var is_activated: bool = false
var detected_player: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_activated:
		player_in_range = true
		detected_player = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and event.is_action_pressed("interact"):
		is_activated = true
		
		# 1. Play the rubble dialogue and wait for it to finish
		if dialogue_resource:
			DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
			await DialogueManager.dialogue_ended
		
		# 2. Unlock the door and save Matcha's rescued state for Scene 2
		Global.found_matcha = true
		NavigationManager.has_matcha = true
		
		# 3. Spawn Matcha and hand Joe Peng directly to it
		_spawn_matcha()

func _spawn_matcha() -> void:
	if matcha_scene == null:
		return
	
	var matcha = matcha_scene.instantiate()
	matcha.player = detected_player
	get_tree().current_scene.add_child(matcha)
	matcha.global_position = spawn_point.global_position
	
	# Small pop-out hop animation
	var target_pos = spawn_point.global_position + Vector2(0, 16)
	var tween = create_tween()
	tween.tween_property(matcha, "global_position", target_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
