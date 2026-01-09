extends Area2D

@export var spawn_destino := "porta_labs"
@export var proxima_cena : String = "res://scenes/stages/Lab.tscn"

func _ready():
	# Conecta o sinal body_entered à função _on_body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):

		Global.spawn_id = spawn_destino
		call_deferred("_trocar_cena")



func _trocar_cena():
	get_tree().change_scene_to_file(proxima_cena)
