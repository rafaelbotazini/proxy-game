extends CharacterBody2D

@export var speed := 40
@export var change_direction_interval := 2.0  # Tempo para mudar de direção\
@onready var sprite = $AnimatedSprite2D

var health := 7
var is_hurt := false

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

	if direction == Vector2.ZERO:
		sprite.play("npcIdle")
	else:
		sprite.play("npcWalking")
		sprite.flip_h = direction.x < 0

func take_damage(amount):
	if is_hurt:
		return  # impede tomar dano múltiplo ao mesmo tempo
	health -= amount
	flash_white()

	if health <= 0:
		is_hurt = true
		die()
		sprite.play("hurt")
	else:
		await sprite.animation_finished
		is_hurt = false

func die():
	queue_free()  # remove o NPC da cena
func flash_white():
	sprite.modulate = Color(1, 1, 1, 0.5)  # Deixa o sprite meio transparente/pálido
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, 1)  # Volta ao normal
