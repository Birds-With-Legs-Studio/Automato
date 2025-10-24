extends CharacterBody2D


@export var speed = 40 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var environment

func _ready():
	screen_size = get_viewport_rect().size
	environment = get_node("../TileMap/TileMapLayer")
	
	
func _process(_delta):
	#Process player movement
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	move_and_slide()
	#position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.animation = "stand"
		
	#Process player interaction
	if Input.is_action_pressed("Place"):
		environment.set_cell(environment.local_to_map(position), 0, Vector2i(1, 1), 0)

	
