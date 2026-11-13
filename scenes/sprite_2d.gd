extends Sprite2D

# How far the arrow should move (e.g., 20 pixels up/down or left/right)
@export var bounce_distance := Vector2(0, 7) 
# How long one bounce takes in seconds
@export var bounce_duration := 0.5 

func _ready():
	# Save the starting position
	var start_pos = position
	var target_pos = start_pos + bounce_distance
	
	# Create an infinite looping tween
	var tween = create_tween().set_loops()
	
	# Smoothly move to the target position, then back to the start
	tween.tween_property(self, "position", target_pos, bounce_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", start_pos, bounce_duration).set_trans(Tween.TRANS_SINE)
