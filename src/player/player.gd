extends CharacterBody2D


@export var speed = 40 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var environment
var facing

func _ready():
	screen_size = get_viewport_rect().size
	environment = get_node("../TileMap/TileMapLayer2")
	facing = 'd'
	
	
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
		#Play a:nimations based on player direction
		if velocity.x > 0:
			facing = 'r'
			$AnimatedSprite2D.animation = "walk_right"
			$AnimatedSprite2D.flip_h = false
		elif velocity.x < 0:
			facing = 'l'
			$AnimatedSprite2D.animation = "walk_right"
			$AnimatedSprite2D.flip_h = true
		elif velocity.y > 0:
			facing = 'd'
			$AnimatedSprite2D.animation = "walk_down"
			$AnimatedSprite2D.flip_h = false
		else:
			facing = 'u'
			$AnimatedSprite2D.animation = "walk_up"
			$AnimatedSprite2D.flip_h = false
		
		
		
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
		var facing_vector
		match facing:
			'r':
				facing_vector = Vector2i(1,0)
			'l':
				facing_vector = Vector2i(-1,0)
			'u':
				facing_vector = Vector2i(0,-1)
			'd':
				facing_vector = Vector2i(0,1)
		environment.set_cell(environment.local_to_map(position) + facing_vector, 0, Vector2(0,0), 0)

	
