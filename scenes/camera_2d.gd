class_name WorldCamera
extends Camera2D

@export var character : Character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if character:
		position = character.position + Vector2.UP * 40
