extends TextureProgressBar

@export var player: Player

func _ready():
	player.healthChanged.connect(update)
	update()


func update():
	@warning_ignore("integer_division")
	value = player.currentHealth * 100 / player.maxHealth
