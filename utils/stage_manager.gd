extends Node

enum StageArea {
	BANHEIRO,
	ENTRADA,
	LAB,
	LOBBY,
	MAPA,
	RUA
}

var STAGES_PATH : Dictionary[StageArea, String] = {
	StageArea.BANHEIRO: "res://scenes/stages/banheiro.tscn",
	StageArea.ENTRADA: "res://scenes/stages/entrada.tscn",
	StageArea.LAB: "res://scenes/stages/lab.tscn",
	StageArea.LOBBY: "res://scenes/stages/lobby.tscn",
	StageArea.MAPA: "res://scenes/stages/mapa.tscn",
	StageArea.RUA: "res://scenes/stages/rua.tscn"
}

signal stage_changed(stage: StageData)
