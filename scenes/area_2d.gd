extends Area2D

@export var matcha_scene: PackedScene

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var indicator: Node2D = $"../indicator (matcha)"

var player_in_range: bool = false
var is_activated: bool = false

func _ready() -> void:
	if NavigationManager.has_matcha and indicator:
		indicator.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_activated:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and event.is_action_pressed("interact"):
		is_activated = true
		NavigationManager.has_matcha = true
		
		if indicator:
			indicator.queue_free()
			
		_spawn_matcha()

func _spawn_matcha() -> void:
	if matcha_scene == null:
		return
	
	var matcha = matcha_scene.instantiate()
	get_parent().add_child(matcha)
	matcha.global_position = spawn_point.global_position
	
	var target_pos = spawn_point.global_position + Vector2(0, 16)
	var tween = create_tween()
	tween.tween_property(matcha, "global_position", target_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
