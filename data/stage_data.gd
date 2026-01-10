class_name StageData
extends Resource

@export var scene_path : String
@export var spawn_name : String

func _init(
	path: String,
	spawn_id: String
) -> void:
	scene_path = path
	spawn_name = spawn_id
