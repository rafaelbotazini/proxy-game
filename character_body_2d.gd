extends CharacterBody2D

@export var speed := 40
@export var change_direction_interval := 2.0  # Tempo para mudar de direção

var direction := Vector2.ZERO
var time_accumulator := 0.0

func _ready():
	_pick_new_direction()

func _physics_process(delta):
	time_accumulator += delta

	# Muda a direção após o tempo definido
	if time_accumulator >= change_direction_interval:
		time_accumulator = 0
		_pick_new_direction()

	# Movimento
	velocity = direction * speed
	move_and_slide()

	_update_animation()

func _pick_new_direction():
	# Escolhe uma direção aleatória entre parada e 8 direções possíveis
	var dirs = [
		Vector2.ZERO,
		Vector2.LEFT, Vector2.RIGHT,
		Vector2.UP, Vector2.DOWN,
		Vector2(-1, -1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(1, 1)
	]
	direction = dirs[randi() % dirs.size()].normalized()

func _update_animation():
	var sprite = $AnimatedSprite2D

	if direction == Vector2.ZERO:
		sprite.play("npcIdle")
	else:
		sprite.play("npcWalking")
		sprite.flip_h = direction.x < 0
