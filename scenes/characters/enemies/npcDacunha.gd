extends CharacterBody2D

# -------------------------
# Configurações do NPC
# -------------------------
@export var speed := 40
@export var change_direction_interval := 2.0
@export var attack_range := 20
@export var attack_damage := 1
@export var chase_range := 325
@export var retreat_time := 0.5
@export var retreat_speed := 102
@export var rush_speed := 120
@export var rush_time := 0.8
@export var retreat_chance := 0.4 # chance de recuar após ataque

@export var wait_time := 1.0   # tempo máximo que o NPC pode ficar parado
var wait_timer := 0.0

@export var max_health := 15
var health := max_health

# Nomes das animações
@export var anim_idle := "npcIdle"
@export var anim_walk := "npcWalking"
@export var anim_attack := "npcAttack"
@export var anim_hurt := "npcHurt"
@export var anim_down := "npcDownIdle"
@export var anim_idlecombat := "npcIdleCombat"

@export var is_security := false

# -------------------------
# Knockdown por vida
# -------------------------
@export var fall_duration := 0.5
@export var down_duration := 20.0
var knockdown_timer_active := false
var knockdown_time := 0.0

# -------------------------
# Knockdown por hits consecutivos
# -------------------------
var hit_count := 0
var max_hits := 5
var knockdown_duration := 4.0
var knockdown_timer := 0.0
var is_knocked_down := false
var combo_timer := 0.0
var max_combo_time := 1.5

var in_combat := false

# -------------------------
# Stun ao levar hit
# -------------------------
var is_stunned := false
@export var stun_duration := 0.5
var stun_timer := 0.0

# -------------------------
# Flag NPC parado
# -------------------------
@export var is_stationary := false

# -------------------------
# Ativar hostilidade por proximidade
# -------------------------
@export var activate_on_proximity := false
@export var proximity_range := 150.0

# -------------------------
# Nós
# -------------------------
@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer

# -------------------------
# Variáveis internas
# -------------------------
var player = null
var buffer = 2.0
var time_accumulator := 0.0
var state := "idle"
var direction := Vector2.ZERO
var can_attack := true
var retreat_timer := 0.0
var rush_timer := 0.0

# -------------------------
# Otimização de performance
# -------------------------
@export var desativar_distancia := 1000.0  # distância máxima antes de desativar o NPC
var ativo := true  # indica se o NPC está ativo (processando)

# -------------------------
# Ready
# -------------------------
func _ready():
	_pick_new_direction()
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))

# -------------------------
# Process principal
# -------------------------
func _physics_process(delta):
	# --- Ativar hostilidade por proximidade ---
	if activate_on_proximity and not player:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var player_candidate = players[0]
			var dist = global_position.distance_to(player_candidate.global_position)
			if dist <= proximity_range:
				player = player_candidate
				in_combat = true

	# Checa distância do player para ativar/desativar o NPC
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist > desativar_distancia and ativo:
			set_process(false)
			set_physics_process(false)
			if sprite:
				sprite.pause()
			ativo = false
			return
		elif dist <= desativar_distancia and not ativo:
			set_process(true)
			set_physics_process(true)
			if sprite:
				sprite.play()
			ativo = true

	if not ativo:
		return

	time_accumulator += delta

	# Atualiza stun
	if is_stunned:
		stun_timer += delta
		if stun_timer >= stun_duration:
			is_stunned = false

	# Knockdown por vida
	if knockdown_timer_active:
		knockdown_time += delta
		if knockdown_time >= fall_duration and sprite.animation != anim_down:
			sprite.play(anim_down)
		if knockdown_time >= fall_duration + down_duration:
			state = "idle"
			can_attack = true
			knockdown_timer_active = false
			health = max_health

		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Knockdown por hits consecutivos
	if is_knocked_down:
		knockdown_timer += delta
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		sprite.modulate = Color(1,1,1,0.5)
		
		move_and_slide()
		if knockdown_timer >= knockdown_duration:
			hit_count = 0
			combo_timer = 0.0
			is_knocked_down = false
			sprite.modulate = Color(1,1,1,1)
			state = "walking"
		return

	# Combo timer
	if hit_count > 0:
		combo_timer += delta
		if combo_timer > max_combo_time:
			hit_count = 0
			combo_timer = 0.0

	# Estados
	match state:
		"idle":
			_idle_state(delta)
		"walking":
			_walking_state(delta)
		"attacking":
			_attacking_state(delta)
		"hurt":
			direction = Vector2.ZERO
			velocity = Vector2.ZERO
		"retreat":
			_retreat_state(delta)
		"rushing":
			_rush_state(delta)
		"waiting":
			_waiting_state(delta)

	velocity = direction * speed
	move_and_slide()
	_update_animation()

# -------------------------
# Estados
# -------------------------
func _idle_state(delta):
	if player and is_instance_valid(player):
		state = "walking"
	else:
		if not is_stationary and time_accumulator >= change_direction_interval:
			time_accumulator = 0
			_pick_new_direction()
			state = "walking"

func _walking_state(delta):
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)

		if distance > chase_range:
			# Player saiu do range
			player = null
			in_combat = false
			state = "idle"
			
			# stationary para, mobile continua idle (vai andar aleatório no idle)
			if is_stationary:
				direction = Vector2.ZERO
				velocity = Vector2.ZERO
			return

		# Player dentro do range, NPC reage
		if distance > attack_range + buffer:
			# Ambos se movem em direção ao player
			direction = (player.global_position - global_position).normalized()
		else:
			# Player no range de ataque
			direction = Vector2.ZERO
			state = "attacking"
	else:
		# NPC idle
		if not is_stationary and time_accumulator >= change_direction_interval:
			time_accumulator = 0
			_pick_new_direction()


func _attacking_state(delta):
	if state == "hurt" or is_stunned:
		return
	if not player or not is_instance_valid(player):
		state = "idle"
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > attack_range + buffer:
		state = "walking"
		return

	# Durante o ataque, se pode atacar, realiza ataque
	if can_attack:
		attack()  # função já existente que inicia o ataque
	else:
		# Pequena pausa entre ataques, NPC fica parado
		direction = Vector2.ZERO
		velocity = Vector2.ZERO

func _retreat_state(delta):
	if not player:
		state ="idle"
		return

	var dir = (global_position - player.global_position).normalized()
	direction = dir
	velocity = dir * retreat_speed

	retreat_timer += delta
	if retreat_timer >= retreat_time:
		retreat_timer = 0.0
		
		var chance = randf()
		if chance < 0.3:
			state = "waiting"
			wait_timer = 0.0
		elif chance < 0.6:
			state = "walking"

func _rush_state(delta):
	if not player:
		state = "idle"
		return

	var dir = (player.global_position - global_position).normalized()
	direction = dir
	velocity = dir * rush_speed * 2

	rush_timer += delta
	if rush_timer >= rush_time:
		rush_timer = 0.0
		state = "walking"

func _waiting_state(delta):
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	sprite.play(anim_idle)
	
	wait_timer += delta
	if wait_timer >= wait_time:
		wait_timer = 0.0
		state = "walking"


# -------------------------
# Animações
# -------------------------
func _update_animation():
	match state:
		"hurt":
			if anim_hurt != "":
				sprite.play(anim_hurt)
				
				

		"attacking":
			if can_attack:
				# Está atacando de fato
				if anim_attack != "":
					sprite.play(anim_attack)
			else:
				# Pausa entre ataques, NPC parado -> idle combat
				if anim_idlecombat != "":
					sprite.play(anim_idlecombat)
			# Flip do sprite para olhar o player
			if player and is_instance_valid(player):
				sprite.flip_h = player.global_position.x < global_position.x


		"walking", "rushing":
			if direction.length() > 0:
				if anim_walk != "":
					sprite.play(anim_walk)
				sprite.flip_h = direction.x < 0
			else:
				if anim_idle != "":
					sprite.play(anim_idle)
		"idle":
			if in_combat:
				if anim_idlecombat != "":
					sprite.play(anim_idlecombat)
			else:
				if anim_idle != "":
					sprite.play(anim_idle)
		"retreat":
			if anim_walk != "":
				sprite.play(anim_walk)
			if player and is_instance_valid(player):
				sprite.flip_h = player.global_position.x < global_position.x
		"charge_attack":
			pass

# -------------------------
# Ataque normal
# -------------------------
func attack():
	if can_attack and state != "hurt" and not is_stunned:
		can_attack = false
		if player:
			player.take_damage(attack_damage)
		attack_timer.start()

func _on_attack_timeout():
	can_attack = true
	var chance = randf()
	if chance < 0.3:
		state = "waiting"
		wait_timer = 0.0
	elif chance < 0.7:
		state = "retreat"
		retreat_timer = 0.0
	else:
		state = "walking"

# -------------------------
# Knockdown
# -------------------------
func take_damage(amount, from_player):
	in_combat = true
	if state == "hurt" or is_knocked_down or knockdown_timer_active:
		return

	health -= amount
	flash_white()
	player = from_player

	hit_count += 1
	combo_timer = 0.0

	is_stunned = true
	stun_timer = 0.0
	
	_alert_security(from_player)

	if hit_count >= max_hits:
		_start_knockdown_hit()
		return

	if health <= 0:
		_start_knockdown()
		flash_white()

	else:
		state = "walking"

func _start_knockdown_hit():
	is_knocked_down = true
	knockdown_timer = 0.0
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	state = "hurt"
	

func _start_knockdown():
	state = "hurt"
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	can_attack = false

	if anim_hurt != "":
		sprite.play(anim_hurt)
	knockdown_timer_active = true
	knockdown_time = 0.0
	queue_free()
	emit_signal("npc_died")

# -------------------------
# Movimento aleatório
# -------------------------
func _pick_new_direction():
	if is_stationary:
		direction = Vector2.ZERO
		return

	var dirs = [
		Vector2.ZERO,
		Vector2.LEFT, Vector2.RIGHT,
		Vector2.UP, Vector2.DOWN,
		Vector2(-1, -1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(1, 1)
	]
	direction = dirs[randi() % dirs.size()].normalized()

# -------------------------
# Segurança: alerta NPCs
# -------------------------
func _alert_security(attacker):
	var npcs = get_tree().get_nodes_in_group("enemies")
	for npc in npcs:
		# Verifica se o node ainda é válido
		if not is_instance_valid(npc):
			continue
		
		# Verifica se é realmente um NPC do tipo CharacterBody2D
		if not npc is CharacterBody2D:
			continue
		
		# Apenas NPCs marcados como segurança reagem
		if npc.is_security:
			var dist = global_position.distance_to(npc.global_position)
			if dist <= 400: # raio de detecção do segurança
				npc.player = attacker
				npc.state = "walking"
				npc.in_combat = true


# -------------------------
# Utilitários
# -------------------------
func die():
	queue_free()
	emit_signal("npc_died")

func flash_white():
	sprite.modulate = Color(1,1,1,0.5)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1,1,1,1)
