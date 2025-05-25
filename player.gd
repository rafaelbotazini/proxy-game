extends CharacterBody2D

const SPEED = 90

@onready var sprite = $AnimatedSprite2D

#Variaveis
var is_attacking = false
var direction := Vector2.ZERO

#função que estará sendo processada a cada momento.
func _physics_process(delta):
	# Impede o movimento e entrada de comandos durante ataque
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

   #Logica para personagem andar
	direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	velocity = direction.normalized() * SPEED
	move_and_slide()

	_update_animation(direction)

	# Verifica se o ataque deve começar
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	#função para inverter a imagem do personagem ao andar
func _update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("player_walking")
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

func start_attack():
	is_attacking = true
	sprite.play("attack")

	# await serve para esperar a animação terminar.
	await sprite.animation_finished

	is_attacking = false

	# Retorna para idle ou walking dependendo do movimento
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("player_walking")
