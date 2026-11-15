extends Area2D

# Drag your matcha.tscn scene from the FileSystem dock into this slot in the Inspector
@export var matcha_scene: PackedScene

@onready var spawn_point: Marker2D = $SpawnPoint
# @onready var prompt_arrow: Sprite2D = $PromptArrow # Uncomment if the arrow is a child node

var player_in_range: bool = false
var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_activated:
		player_in_range = true
		# prompt_arrow.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		# prompt_arrow.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and event.is_action_pressed("interact"):
		is_activated = true
		# prompt_arrow.visible = false
		_spawn_matcha()

func _spawn_matcha() -> void:
	if matcha_scene == null:
		return
	
	var matcha = matcha_scene.instantiate()
	# Add Matcha to the current level scene (not inside RubbleSpot) so Matcha can move freely
	get_parent().add_child(matcha)
	matcha.global_position = spawn_point.global_position
	
	# Small pop-out hop animation using a Tween so Matcha emerges smoothly from the pit
	var target_pos = spawn_point.global_position + Vector2(0, 16) # Steps slightly below the crater
	var tween = create_tween()
	tween.tween_property(matcha, "global_position", target_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
