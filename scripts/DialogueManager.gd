extends Node

var in_dialogue := false

func start(dialogue_id: String, npc_name: String):
	if in_dialogue:
		return
	
	in_dialogue = true
	print("Iniciando diálogo:", dialogue_id, "com", npc_name)

	# aqui depois entra UI, texto, quest etc
