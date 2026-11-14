extends CharacterBody2D

@export var speed = 150
@onready var anim = $AnimatedSprite2D

# We store the last direction to know which idle animation to play
var current_dir = "down" 

func _physics_process(delta):
	# 1. Get the player's input (returns a Vector2 like (1, 0) for right)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Apply the movement
	velocity = input_dir * speed
	move_and_slide()
	
	# 3. Update Animations
	if input_dir.length() > 0:
		# The player is pressing a key, so play walking animations
		if input_dir.x != 0:
			anim.play("walk_side")
			current_dir = "side"
			# Flip the sprite horizontally if moving left
			anim.flip_h = input_dir.x < 0
			
		elif input_dir.y < 0:
			anim.play("walk_up")
			current_dir = "up"
			
		elif input_dir.y > 0:
			anim.play("walk_down")
			current_dir = "down"
			
	else:
		# The player stopped pressing keys, so play idle animations
		if current_dir == "side":
			anim.play("idle_side")
		elif current_dir == "up":
			anim.play("idle_up")
		elif current_dir == "down":
			anim.play("idle_down")
