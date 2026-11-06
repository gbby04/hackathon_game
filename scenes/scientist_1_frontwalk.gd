extends CharacterBody2D

# Adjust speed to fit your project scaling
@export var speed: float = 100.0

# Reference to your AnimatedSprite2D child node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Reset horizontal/vertical velocity direction each frame
	var direction := Vector2.ZERO
	
	# Read input axes (keyboard arrow keys or WASD)
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Normalize diagonal movement so walking diagonally isn't faster
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Apply speed to velocity
	velocity = direction * speed
	
	# Execute physics movement
	move_and_slide()
	
	# Handle animation states
	update_animation(direction)

func update_animation(dir: Vector2) -> void:
	# When moving down (towards the camera / front)
	if dir.y > 0:
		animated_sprite.play("walk_front") # Make sure this matches your animation name in SpriteFrames!
	# If stationary
	elif dir == Vector2.ZERO:
		animated_sprite.play("idle_front") # Make sure this matches your idle animation name
