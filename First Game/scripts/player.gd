extends CharacterBody2D

# Constants
const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.5
const GRAVITY = 980.0  # Fixed gravity value
const ACCELERATION = 12.0
const DECELERATION = 8.0
const MAX_SPEED = 150.0

# State Tracking
var dash_time = 0.0
var dash_cooldown = 0.0
var can_dash = true
var is_wall_sliding = false

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
# Removed wall checks by default, add these back only if you set up the nodes
#@onready var wall_check_left = $WallCheckLeft
#@onready var wall_check_right = $WallCheckRight

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	handle_movement(delta)
	handle_dash(delta)
	# handle_wall_slide(delta)  # Disabled by default

	move_and_slide()
	handle_animations()

func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = lerp(velocity.x, float(direction) * MAX_SPEED, ACCELERATION * delta)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Wall jumping removed for now (needs wall slide)

func handle_dash(delta):
	if dash_cooldown > 0:
		dash_cooldown -= delta
		if dash_cooldown <= 0:
			can_dash = true

	if can_dash and Input.is_action_just_pressed("dash"):
		var dash_direction = 1 if not animated_sprite.flip_h else -1
		velocity.x = dash_direction * DASH_SPEED
		dash_time = DASH_DURATION
		dash_cooldown = DASH_COOLDOWN
		can_dash = false
		animated_sprite.play("dash")

	if dash_time > 0:
		dash_time -= delta
		if dash_time <= 0:
			velocity.x = 0

# Wall slide removed for now
#func handle_wall_slide(delta):
#    var touching_wall = (wall_check_left.is_colliding() and velocity.x < 0) or (wall_check_right.is_colliding() and velocity.x > 0)
#    if touching_wall and not is_on_floor():
#        is_wall_sliding = true
#        velocity.y = min(velocity.y, GRAVITY * 0.5)
#    else:
#        is_wall_sliding = false

func handle_animations():
	if is_on_floor():
		if abs(velocity.x) > 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	elif dash_time > 0:
		animated_sprite.play("dash")
	else:
		animated_sprite.play("jump")
