extends Node2D

func _process(delta):
	for child in get_children():
		if child is Node2D and child.has_method("get_position"):
			child.z_index = int(child.global_position.y)





@onready var world = $y_sorting

func _ready():
	if Global.spawn_id == "":
		return

	# espera TUDO carregar
	await get_tree().process_frame
	await get_tree().process_frame

	var spawn = world.get_node_or_null("Spawn_" + Global.spawn_id)
	var player = world.get_node_or_null("Player")

	if spawn and player:
		player.global_position = spawn.global_position
		print("Player reposicionado:", spawn.global_position)

	# limpa para não reaplicar
	Global.spawn_id = ""
