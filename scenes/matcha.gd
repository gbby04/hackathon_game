extends CharacterBody2D

@export var follow_speed: float = 95.0
@export var follow_distance: float = 20.0 # Keeps a small gap so Matcha doesn't overlap the player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D # Or $Sprite2D

var player: Node2D = null

func _ready() -> void:
	# Ensure Matcha renders slightly above the player/ground since it's flying
	z_index = 2
	player = get_tree().get_first_node_in_group("player")
	if anim and anim is AnimatedSprite2D:
		anim.play("fly") # Replace with your flying animation name

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Target a floating offset slightly above and behind the player
	var target_pos = player.global_position + Vector2(-14, -28)
	var distance = global_position.distance_to(target_pos)
	
	if distance > 2.0:
		var direction = (target_pos - global_position).normalized()
		# Slows down smoothly as Matcha gets close to the player
		var current_speed = min(follow_speed, distance * 5.0)
		velocity = direction * current_speed
		
		# Flip sprite left/right based on horizontal movement
		if direction.x != 0 and anim:
			anim.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
