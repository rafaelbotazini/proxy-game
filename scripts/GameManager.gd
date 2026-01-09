extends Node

# -----------------------------
# 🎮 GameManager — Controle Global
# -----------------------------

# Missão e progresso atual
var current_mission: int = 1
var current_step: int = 0
var current_scene: String = "CASA"

# Estrutura das missões e objetivos
var missions := {
	1: [
		{"scene": "CASA", "objective": "Sair de casa"},
		{"scene": "RUA", "objective": "Ir até a escola"},
		{"scene": "SALA_DE_AULA", "objective": "Assistir à cutscene"},
		{"scene": "RUA", "objective": "Conversar com o NPC"},
		{"scene": "RUA", "objective": "Derrotar inimigos"},
		{"scene": "SALA_DE_AULA", "objective": "Cutscene final"},
	]
}

# ----------------------------------------------------------
# 🔄 Função para ir para o próximo passo / cena
# ----------------------------------------------------------
func next_step():
	current_step += 1
	
	if current_step >= missions[current_mission].size():
		print("Missão concluída!")
		return
	
	var step = missions[current_mission][current_step]
	current_scene = step["scene"]
	
	print("Indo para:", current_scene, " | Objetivo:", step["objective"])
	get_tree().change_scene_to_file("res://scenes/stages/%s.tscn" % current_scene)

# ----------------------------------------------------------
# 💾 Funções de salvar e carregar progresso
# ----------------------------------------------------------
func save_game():
	var save_data = {
		"mission": current_mission,
		"step": current_step,
	}
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	print("Jogo salvo!")

func load_game():
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		var data = file.get_var()
		file.close()
		current_mission = data["mission"]
		current_step = data["step"]
		print("Jogo carregado! Missão:", current_mission, "Etapa:", current_step)
	else:
		print("Nenhum save encontrado.")
