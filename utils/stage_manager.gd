extends Node

enum Stage {
	BANHEIRO,
	ENTRADA,
	LAB,
	LOBBY,
	MAPA,
	RUA
}

var STAGES : Dictionary[Stage, String] = {
	Stage.BANHEIRO: "res://scenes/stages/banheiro.tscn",
	Stage.ENTRADA: "res://scenes/stages/entrada.tscn",
	Stage.LAB: "res://scenes/stages/lab.tscn",
	Stage.LOBBY: "res://scenes/stages/lobby.tscn",
	Stage.MAPA: "res://scenes/stages/mapa.tscn",
	Stage.RUA: "res://scenes/stages/rua.tscn"
}

func _ready() -> void:
	pass # Replace with function body.
