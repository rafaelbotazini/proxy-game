class_name Character
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $CharacterSprite 

enum State {ATTACK, DEFENSE, IDLE, KNOCKBACK, WALK}

var anim_map = {
	State.ATTACK: "attack",
	State.DEFENSE: "defense",
	State.IDLE: "idle",
	State.KNOCKBACK: "idle",
	State.WALK: "walk",
}

@export var current_health = 40
@export var max_health = 40
@export var speed = 300.0

var current_state : State = State.IDLE
var heading = Vector2.RIGHT

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_death(delta)
	set_heading()
	flip_sprites()
	move_and_slide()

func handle_input() -> void:
	pass

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			current_state = State.IDLE
		else:
			current_state = State.WALK

func handle_animations() -> void:
	var animation_name = anim_map[current_state]
	if (sprite.sprite_frames.has_animation(animation_name)):
		sprite.play(animation_name)

func handle_death(_delta: float) -> void:
	pass

func set_heading() -> void:
	pass

func flip_sprites() -> void:
	sprite.flip_h = heading == Vector2.LEFT

func can_move():
	return current_state == State.IDLE or current_state == State.WALK
