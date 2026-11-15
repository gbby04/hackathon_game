extends CharacterBody2D

@export var follow_speed: float = 95.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null
var can_follow: bool = false

func _ready() -> void:
	z_index = 5
	collision_layer = 0
	collision_mask = 0
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if anim:
		anim.play("fly")
	
	await get_tree().create_timer(0.4).timeout
	can_follow = true

func _physics_process(delta: float) -> void:
	if not can_follow or player == null:
		return
	
	var target_pos = player.global_position + Vector2(-14, -28)
	var distance = global_position.distance_to(target_pos)
	
	if distance > 2.0:
		var direction = (target_pos - global_position).normalized()
		var current_speed = min(follow_speed, distance * 5.0)
		global_position += direction * current_speed * delta
		
		if direction.x != 0 and anim:
			anim.flip_h = direction.x < 0
