extends Node2D

@onready var bubble := $DialogueBubble

func _ready():
	bubble.visible = false

func _on_interaction_area_body_entered(body):
	if body.is_in_group("Player"):
		bubble.visible = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group("Player"):
		bubble.visible = false
