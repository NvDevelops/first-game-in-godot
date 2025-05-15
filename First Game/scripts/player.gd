extends CharacterBody2D

# Constants
const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.5
const GRAVITY = 980.0
const ACCELERATION = 12.0
const DECELERATION = 8.0
const MAX_SPEED = 150.0

# State Tracking
var dash_time = 0.0
var dash_cooldown = 0.0
var can_dash = true

# Mobile Input Tracking
var left_pressed = false
var right_pressed = false
var jump_pressed = false
var dash_pressed = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	handle_movement(delta)
	handle_dash(delta)
	move_and_slide()
	handle_animations()

func handle_movement(delta):
	var direction = 0
	if left_pressed and not right_pressed:
		direction = -1
	elif right_pressed and not left_pressed:
		direction = 1
	else:
		direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = lerp(velocity.x, float(direction) * MAX_SPEED, ACCELERATION * delta)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)

	var jump_now = Input.is_action_just_pressed("jump") or jump_pressed
	if jump_now and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_pressed = false # For mobile: only jumps once per tap

func handle_dash(delta):
	if dash_cooldown > 0:
		dash_cooldown -= delta
		if dash_cooldown <= 0:
			can_dash = true

	var dash_now = Input.is_action_just_pressed("dash") or dash_pressed
	if can_dash and dash_now:
		var dash_direction = 1 if not animated_sprite.flip_h else -1
		velocity.x = dash_direction * DASH_SPEED
		dash_time = DASH_DURATION
		dash_cooldown = DASH_COOLDOWN
		can_dash = false
		animated_sprite.play("dash")
		dash_pressed = false

	if dash_time > 0:
		dash_time -= delta
		if dash_time <= 0:
			velocity.x = 0

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

# BUTTON SIGNALS (connect these in the editor for each button)
func _on_left_button_button_down():
	left_pressed = true
func _on_left_button_button_up():
	left_pressed = false

func _on_right_button_button_down():
	right_pressed = true
func _on_right_button_button_up():
	right_pressed = false

func _on_jump_button_button_down():
	jump_pressed = true
func _on_jump_button_button_up():
	jump_pressed = false

func _on_dash_button_button_down():
	dash_pressed = true
func _on_dash_button_button_up():
	dash_pressed = false
