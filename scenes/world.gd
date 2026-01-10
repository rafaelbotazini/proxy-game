class_name World
extends Node2D

var DEFAULT_SCENE_PREFAB = preload("res://scenes/stages/mapa.tscn")
var PLAYER_PREFAB = preload("res://scenes/characters/player.tscn")

@onready var actors : Node2D = $ActorsContainer
@onready var camera : WorldCamera = $Camera2D
@onready var stage : Node2D = $Stage

var player: Player

func _init() -> void:
	StageManager.stage_changed.connect(on_stage_change.bind())


func _ready() -> void:
	var scene: Stage = DEFAULT_SCENE_PREFAB.instantiate()
	load_stage(scene)


func on_stage_change(data: StageData) -> void:
	print("received", data)
	var res: PackedScene = load(data.scene_path)
	var scene: Stage = res.instantiate()
	load_stage(scene, data.spawn_name)


func load_stage(scene: Stage, spawn_id: String = "Default") -> void:
	for child in stage.get_children():
		stage.remove_child.call_deferred(child)
		child.queue_free()

	for child in actors.get_children():
		actors.remove_child.call_deferred(child)
		child.queue_free()

	player = PLAYER_PREFAB.instantiate()
	camera.character = player

	scene.ready.connect(func (): add_scene_nodes(scene, spawn_id), CONNECT_ONE_SHOT)

	stage.add_child.call_deferred(scene)


func add_scene_nodes(scene: Stage, spawn_id: String) -> void:
	var scene_actors = scene.actors
	scene.remove_child(scene_actors)

	actors.add_child(scene_actors)
	actors.add_child(player)

	scene.teleport_player(player, spawn_id)
