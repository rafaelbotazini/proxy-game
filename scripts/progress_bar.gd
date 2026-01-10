extends TextureProgressBar

@export var player: Player

func _ready():
	if player != null:
		#player.healthChanged.connect(update)
		update()


func update():
	@warning_ignore("integer_division")
	value = player.current_health * 100 / player.max_health
