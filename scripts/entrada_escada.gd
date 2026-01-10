extends Area2D

# Caminho da próxima cena (você pode alterar no Inspector)
@export var spawn_destino := "porta_entrada_lobby"
@export var proxima_cena : String = StageManager.STAGES_PATH[StageManager.StageArea.LOBBY]

func _ready():
	# Conecta o sinal body_entered à função _on_body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
	
		Global.spawn_id = spawn_destino
		call_deferred("_trocar_cena")

func _trocar_cena():
	get_tree().change_scene_to_file(proxima_cena)
