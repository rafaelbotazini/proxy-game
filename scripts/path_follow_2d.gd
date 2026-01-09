extends PathFollow2D

@export var speed := 50.0          # velocidade do NPC
@export var walk_time := 2.5       # tempo andando (segundos)
@export var wait_time := 1.5       # tempo parado (segundos)
@export var reverse := true        # se pode voltar no caminho

var direction := 1
var timer := 0.0
var is_waiting := false

func _process(delta):
	if is_waiting:
		timer -= delta
		if timer <= 0.0:
			is_waiting = false
		return

	# anda no caminho
	progress += direction * speed * delta

	# se chegou ao final ou início
	if progress_ratio >= 1.0 or progress_ratio <= 0.0:
		if reverse:
			direction *= -1 # inverte o sentido
		else:
			progress = 0.0  # reinicia o caminho

	# controla pausa
	timer += delta
	if timer >= walk_time:
		timer = wait_time
		is_waiting = true
