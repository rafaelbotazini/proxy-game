class_name Player

extends Character

func handle_input() -> void:
	if can_move():
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * speed

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT
