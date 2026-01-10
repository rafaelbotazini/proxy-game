extends Character

class_name Player
signal healthChanged

@onready var attack_area = $AttackArea
@onready var regen_timer: Timer = $RegenTimer

# Variáveis
var is_attacking = false
var direction := Vector2.ZERO
var is_hurt := false
var is_defending := false
var is_knockdown := false  # Novo: está nockeado
var knockdown_timer := 0.0
var knockdown_duration := 2.5  # Tempo que fica caído

# Hits consecutivos
var consecutive_hits := 0
var max_consecutive_hits := 4
var combo_timer := 0.0
var max_combo_time := 1.5  # tempo máximo entre hits para resetar combo

func _physics_process(delta):
	if is_knockdown:
		# Player imóvel durante nockdown
		velocity = Vector2.ZERO
		move_and_slide()
		knockdown_timer += delta
		if knockdown_timer >= knockdown_duration:
			recover_from_knockdown()
		return

	# Resetar combo se passar muito tempo
	if consecutive_hits > 0:
		combo_timer += delta
		if combo_timer > max_combo_time:
			consecutive_hits = 0
			combo_timer = 0.0

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Input.is_action_pressed("defend"):
		is_defending = true
		velocity = Vector2.ZERO
		sprite.play("defense")
		move_and_slide()
		return
	else:
		is_defending = false

	# Movimento
	direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()
	_update_animation(direction)

	# Ataque
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func _update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walking")
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

	
func _ready():
	attack_area.connect("body_entered", _on_attack_hit)
	attack_area.monitoring = false
	regen_timer.timeout.connect(Callable(self, "_on_regen_timeout"))

	await get_tree().process_frame
	await get_tree().process_frame

	print("SPAWN_ID NO PLAYER:", Global.spawn_id)

	if Global.spawn_id == "":
		print("❌ spawn_id vazio, usando posição do editor")
		return

	# PROCURA O SPAWN EM QUALQUER LUGAR DA CENA
	var root = get_tree().current_scene
	var spawn = root.find_child("Spawn_" + Global.spawn_id, true, false)

	if spawn:
		global_position = spawn.global_position
		print("✅ PLAYER TELEPORTADO PARA:", spawn.global_position)
	else:
		print("❌ Spawn NÃO encontrado:", "Spawn_" + Global.spawn_id)

	Global.spawn_id = ""


func _on_regen_timeout():
	if current_health < max_health:
		current_health += 2
		healthChanged.emit()

func start_attack():
	is_attacking = true
	sprite.play("attack")
	attack_area.monitoring = true
	await sprite.animation_finished
	is_attacking = false
	attack_area.monitoring = false
	if direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walking")

func _on_attack_hit(body):
	if body.is_in_group("enemies"):
		body.take_damage(1, self)

# ------------------------- 
# Modificado: take_damage com nockdown
# -------------------------
func take_damage(amount):
	if is_hurt or is_knockdown:
		return

	is_hurt = true

	# Defend reduz dano
	var final_damage = amount / 2 if is_defending else amount
	current_health = clamp(current_health - final_damage, 0, max_health)
	healthChanged.emit()
	flash_white()

	# Contador de hits consecutivos
	consecutive_hits += 1
	combo_timer = 0.0

	if consecutive_hits >= max_consecutive_hits:
		enter_knockdown()
		return

	if current_health <= 0:
		die()
	else:
		await get_tree().create_timer(0.5).timeout
		is_hurt = false

func enter_knockdown():
	is_knockdown = true
	knockdown_timer = 0.0
	consecutive_hits = 0
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	is_attacking = false
	is_defending = false
	sprite.play("down")  # Coloque a animação de cair

func recover_from_knockdown():
	is_knockdown = false
	is_hurt = false
	knockdown_timer = 0.0
	sprite.play("idle")

func flash_white():
	sprite.modulate = Color(1,1,1,0.5)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1,1,1,1)

func die():
	queue_free()
