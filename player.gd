extends CharacterBody2D

const SPEED = 100

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	# Movimento
	velocity = direction.normalized() * SPEED
	move_and_slide()

	# Animação
	_update_animation(direction)

func _update_animation(direction: Vector2):
	var sprite = $AnimatedSprite2D

	if direction == Vector2.ZERO:
		sprite.stop()
	else:
		sprite.play("player_walking")
		# Vira horizontalmente se andar pra esquerda
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
