extends CharacterBody2D


@export var speed = 40 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var environment
var camera
@export var inventory: Inventory
@export var hotbar: Hotbar
var rock = preload("res://src/items/rock.tscn")
#0 = left, 1 = up, 2 = right, 3 = down
#TODO: There's GOT to be a better way to do thi
var direction : int


func _ready():
	screen_size = get_viewport_rect().size
	environment = get_node("../TileMap/TileMapLayer2")
	camera = get_node("Camera2D")
	direction = 3


# Process player movement
func _physics_process(_delta):
	# Get player's movement vector from input
	velocity = Input.get_vector("left", "right", "up", "down")
	
	# Determine player direction based on movement (prefer horizontal)
	if velocity.x != 0:
		@warning_ignore("narrowing_conversion")
		direction = velocity.x + 1
	elif velocity.y != 0:
		@warning_ignore("narrowing_conversion")
		direction = velocity.y + 2
	
	# Set velocity to normalized vector and move player
	velocity = velocity.normalized() * speed
	move_and_slide()
	
	# Play animations
	# TODO: Should this go somewhere else?
	if velocity.length() > 0:
		match direction:
			0: 
				$AnimatedSprite2D.animation = "walk_right"
			1:
				$AnimatedSprite2D.animation = "walk_up"
			2:
				$AnimatedSprite2D.animation = "walk_right"
			3:
				$AnimatedSprite2D.animation = "walk_down"
		$AnimatedSprite2D.play()
	else:
		match direction:
			0: 
				$AnimatedSprite2D.animation = "stand_right"
			1:
				$AnimatedSprite2D.animation = "stand_up"
			2:
				$AnimatedSprite2D.animation = "stand_right"
			3:
				$AnimatedSprite2D.animation = "stand_down"
		$AnimatedSprite2D.stop()
	# Flip_h is true only if player is facing left
	$AnimatedSprite2D.flip_h = direction == 0


#Process mouse presses
func _input(event):
	#If it's a mouse event, process click
	if event is InputEventMouseButton and event.pressed:
		# TODO: This is kind of an unideal way to get mouse position. Figure out later
		var place_vector = environment.local_to_map(camera.get_global_mouse_position())
		
		var d_from_player = place_vector - environment.local_to_map(position)
		# If clicked location is within 1 cell of player, change direction accordingly (prefer verical)
		if int(d_from_player.length()) == 1:
			if d_from_player.y != 0:
				direction = d_from_player.y + 2
			else:
				direction = d_from_player.x + 1
		# Otherwise, change place vector to cell in front of player
		else:
			place_vector = environment.local_to_map(position)
			if direction % 2 == 0:
				place_vector += Vector2i(direction - 1, 0)
			else:
				place_vector += Vector2i(0, direction - 2)
		
		# Left button = place, right button = destroy
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not environment.get_cell_tile_data(place_vector):
				if inventory.retrieve_index(hotbar.selected):
					environment.set_cell(place_vector, 0, Vector2(0,0), 0)
					hotbar.update()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if environment.get_cell_tile_data(place_vector):
				inventory.add_item(rock.instantiate(), 1)
				environment.set_cell(place_vector, -1, Vector2(0,1), 0)
				hotbar.update()
