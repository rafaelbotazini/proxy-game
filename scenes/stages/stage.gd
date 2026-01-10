class_name Stage
extends Node2D

@export var locations: Array[Node2D] = []

@onready var actors: Node = $Actors
@onready var spawn_points : Array[Node] = $SpawnPoints.get_children()
@onready var default_spawn : Node2D = $SpawnPoints/Default


func _init() -> void:
	StageManager.stage_changed.connect(on_stage_changed.bind())

func on_stage_changed(_data: StageData) -> void:
	pass

func teleport_player(player: Node2D, spawn_id: String) -> bool:
	for point in spawn_points:
		if point is Node2D and point.name == spawn_id:
			player.position = point.position
			return true
	player.position = default_spawn.position
	return false
