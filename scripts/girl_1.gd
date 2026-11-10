extends CharacterBody2D

const SPEED = 150.0

@onready var animated_sprite = $AnimatedSprite2D

# Variable to remember the last direction the player faced
var last_facing = "front" # Can be "front", "back", or "side"

func _physics_process(delta: float) -> void:
	# 1. Get 4-directional input
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction:
		velocity = direction * SPEED
		
		# 2. Walking logic & saving last facing direction
		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("girl1_walk_side")
			animated_sprite.flip_h = direction.x < 0
			last_facing = "side"
		else:
			animated_sprite.flip_h = false
			if direction.y > 0:
				animated_sprite.play("girl1_walk_down")
				last_facing = "front"
			else:
				animated_sprite.play("girl1_walk_up")
				last_facing = "back"
				
	else:
		# Stop moving smoothly
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
		# 3. Idle logic: Play the correct idle animation based on last facing direction
		# (Make sure to change these names if your idle animations are named differently!)
		if last_facing == "side":
			animated_sprite.play("girl1_idle_side") # Or whatever your side idle is named
		elif last_facing == "back":
			animated_sprite.play("girl1_idle_up") # Or whatever your back idle is named
		else:
			animated_sprite.play("girl1_idle_down") # Or whatever your front idle is named

	# 4. Move the character
	move_and_slide()
