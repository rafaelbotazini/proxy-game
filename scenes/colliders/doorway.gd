class_name Doorway
extends Area2D

@export_enum (
	"res://scenes/stages/banheiro.tscn",
	"res://scenes/stages/entrada.tscn",
	"res://scenes/stages/lab.tscn",
	"res://scenes/stages/lobby.tscn",
	"res://scenes/stages/mapa.tscn",
	"res://scenes/stages/rua.tscn"
) var stage_path: String

@export var spawn_id: String  = "Default"

func _ready() -> void:
	body_entered.connect(on_body_entered.bind())

func on_body_entered(_player: Node2D) -> void:
	print("emit ", stage_path, name)
	StageManager.stage_changed.emit(StageData.new(stage_path, spawn_id))
