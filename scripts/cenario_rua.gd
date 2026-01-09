extends Node2D

@onready var npc = $Npc
@onready var porta = $porta

func _ready():
	porta.trancada = true
	npc.connect("npc_died", Callable(self, "_on_npc_died"))

func _on_npc_died():
	print("NPC derrotado! Porta destrancada.")
	porta.ativar()
