extends Area2D

# Caminho da próxima cena (você pode alterar no Inspector)
@export var spawn_destino := "escada_entrada"
@export var proxima_cena = StageManager.STAGES_PATH[StageManager.StageArea.ENTRADA]

func _ready():
	# Conecta o sinal body_entered à função _on_body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
	
		Global.spawn_id = spawn_destino
		_trocar_cena.call_deferred()

func _trocar_cena():
	get_tree().change_scene_to_file(proxima_cena)
