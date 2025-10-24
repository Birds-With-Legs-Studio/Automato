extends CharacterBody2D


@export var speed = 40 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var environment
var facing

func _ready():
	screen_size = get_viewport_rect().size
	environment = get_node("../TileMap/TileMapLayer")
	facing = 'd'
	
	
func _process(_delta):
	#Process player movement
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		facing = 'r'
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		facing = 'l'
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = true
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		facing = 'd'
		$AnimatedSprite2D.animation = "walk_down"
		$AnimatedSprite2D.flip_h = false
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		facing = 'u'
		$AnimatedSprite2D.animation = "walk_up"
		$AnimatedSprite2D.flip_h = false

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		move_and_slide()
		$AnimatedSprite2D.play()

	else:
		match facing:
			'r':
				$AnimatedSprite2D.animation = "stand_right"
				$AnimatedSprite2D.flip_h = false
			'l':
				$AnimatedSprite2D.animation = "stand_right"
				$AnimatedSprite2D.flip_h = true
			'u':
				$AnimatedSprite2D.animation = "stand_up"
				$AnimatedSprite2D.flip_h = false
			'd':
				$AnimatedSprite2D.animation = "stand_down"
				$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.stop()
	
		
	#Process player interaction
	if Input.is_action_pressed("Place"):
		environment.set_cell(environment.local_to_map(position), 0, Vector2i(1, 1), 0)

	
