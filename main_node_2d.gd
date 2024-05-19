extends Node2D


var snakeSegmentScene = preload(("res://snake_segment.tscn"))

# enums
enum Direction {UP, DOWN, LEFT, RIGHT}

# constants
const start_direction = Direction.RIGHT
const pixels_per_cell = 50
const cellsPerScene = 20
#const startPosition = Vector2(8, 9)
const startSnakeLength = 4

# variables
var direction: Direction
var score: int
var canMove: bool
var food_position: Vector2
var respawn_food: bool
var game_stopped: bool

var snakeSegments = []
var snakePositions = []

var moveTimer = 0.2
var moveTime = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_game()
	#score = 0
	#canMove = true
	#direction = Direction.RIGHT
	#for i in range(startSnakeLength):
		#var segment = snakeSegmentScene.instantiate()
		#segment.position = Vector2(((cellsPerScene / 2) * pixels_per_cell) - (i * pixels_per_cell), (cellsPerScene / 2) * pixels_per_cell)
		#add_child(segment)
		#snakeSegments.append(segment)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not game_stopped:
		moveTime += delta
		if (moveTime >= moveTimer):
			moveTime = 0
			move_snake()

#ready 
func initialize_game():
	get_tree().paused = false
	score = 0;
	canMove = true
	direction = start_direction
	respawn_food = true
	game_stopped = false
	$GameOverMenu.hide()
	initialize_snake()
	spawn_food()
	
func initialize_snake():
	clear_node()
	snakePositions.clear()
	snakeSegments.clear()
	
	for i in range(startSnakeLength):
		var segment = snakeSegmentScene.instantiate()
		segment.position = Vector2(((cellsPerScene / 2) * pixels_per_cell) - (i * pixels_per_cell), (cellsPerScene / 2) * pixels_per_cell)
		add_child(segment)
		snakeSegments.append(segment)
		snakePositions.append(segment.position)
		
func clear_node():
	get_tree().call_group("segments", "queue_free")

func spawn_food():
	var random_x_cell_position = randi_range(1, cellsPerScene - 2)
	var random_y_cell_position = randi_range(1, cellsPerScene - 2)
	food_position = Vector2(random_x_cell_position * pixels_per_cell, random_y_cell_position * pixels_per_cell)
	if (validate_food_position(food_position) == true):
		$Food.position = food_position

func validate_food_position(food_position: Vector2):
	for i in snakePositions:
		if (food_position == i):
			return false
	return true
	
func check_collisions(new_position: Vector2):
	check_bounds(new_position)
	check_snake_collision(new_position)
		
func check_bounds(new_position: Vector2):
	if (new_position.x < 0 
		or new_position.x > ((cellsPerScene - 1) * pixels_per_cell)
		or new_position.y < 0 
		or new_position.y > ((cellsPerScene - 1) * pixels_per_cell)):
		end_game()
		
func check_snake_collision(new_position: Vector2):
	for i in snakePositions:
		if new_position == i:
			end_game()
			
func check_food_collistion(new_position: Vector2):
	if new_position == food_position:
		return true
		
func move_snake():
	var orig_position = snakeSegments[0].position
	var new_position = Vector2(orig_position.x, orig_position.y)
	match direction:
		Direction.UP:
			new_position.y -= pixels_per_cell
		Direction.DOWN:
			new_position.y += pixels_per_cell
		Direction.LEFT:
			new_position.x -= pixels_per_cell
		Direction.RIGHT:
			new_position.x += pixels_per_cell
	
	check_collisions(new_position)
	if game_stopped:
		return
	
	if (check_food_collistion(new_position)):
		insert_new_segment(new_position)
		spawn_food()
		update_score()
	else:
		remove_tail_segment()
		insert_new_segment(new_position)
	
	
	
func update_score():
	score += 1
	
func remove_tail_segment():
	var tail = snakeSegments.pop_back()
	remove_child(tail)
	snakePositions.pop_back()

func insert_new_segment(new_segment_position: Vector2):
	var new_segment = snakeSegmentScene.instantiate()
	new_segment.position = new_segment_position
	add_child(new_segment)
	snakeSegments.push_front(new_segment)
	snakePositions.push_front(new_segment_position)
	
func end_game():
	game_stopped = true
	$GameOverMenu.get_node("ScoreLabel").text = "SCORE: " + str(score)
	$GameOverMenu.show()
	get_tree().paused = true
	
func _input(event):
	if event.is_action_pressed("up_arrow") and direction != Direction.DOWN:
		direction = Direction.UP
	elif event.is_action_pressed("down_arrow") and direction != Direction.UP:
		direction = Direction.DOWN
	elif event.is_action_pressed("left_arrow") and direction != Direction.RIGHT:
		direction = Direction.LEFT
	elif event.is_action_pressed("right_arrow") and direction != Direction.LEFT:
		direction = Direction.RIGHT



func _on_game_over_menu_restart():
	initialize_game()
