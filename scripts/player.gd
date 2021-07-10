extends KinematicBody2D

export var move_force: Vector2
export var wall_jump_force: Vector2
export var gravity: float
export var acc_grav: float
export var friction: float
export var wall_friction: float

var velocity: Vector2

var wall_normal: Vector2

var canJump: bool = false
var right: bool = false
var left: bool = false
var jump: bool = false

enum State {idle, running, wall, jumping}
var state = State.idle

func _ready():
	$anim.animation_set_next("run start", "run")
	$anim.animation_set_next("land", "idle")
	$anim.animation_set_next("into wall slide", "wall slide")
	pass

func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2.UP)

	match state:
		State.idle:
			apply_run_force()
			jump_if_possible()
			if right or left:
				$anim.play("run start")
				velocity = move_and_slide(velocity, Vector2.UP)
				velocity = move_and_slide(velocity, Vector2.UP)
				state = State.running
		State.running:
			apply_run_force()
			jump_if_possible()
			if !right and !left:
				$anim.play("idle")
				state = State.idle
		State.wall:
			if velocity.y > 0:
				velocity.y *= 1 - wall_friction * delta
			if is_on_floor():
				$anim.play("idle")
				state = State.idle
			if jump and !is_on_floor() and canJump:
				wall_jump()
				state = State.jumping
		State.jumping:
			apply_run_force()
			if is_on_floor() and velocity.y >= 0:
				$anim.play("land")
				state = State.idle
			if !is_on_floor() and is_on_wall():
				$anim.play("into wall slide")
				set_wall_normal()
				if velocity.y > 0:
					velocity.y /= 8
				canJump = true
				state = State.wall
	
	velocity.x *= 1 - friction * delta
	velocity.y += gravity * delta
	velocity.y += abs(velocity.y) * acc_grav * delta
	
	if velocity.y > move_force.y * 2:
		velocity.y = move_force.y * 2

func _input(event):
	if event.is_action_pressed("ui_right"):
		right = true
	if event.is_action_pressed("ui_left"):
		left = true
	if event.is_action_pressed("ui_up"):
		jump = true

	if event.is_action_released("ui_right"):
		right = false
	if event.is_action_released("ui_left"):
		left = false
	if event.is_action_released("ui_up"):
		jump = false


func apply_run_force():
	if right:
		$sprite.flip_h = false
		velocity.x += move_force.x
	if left:
		$sprite.flip_h = true
		velocity.x -= move_force.x

func jump_if_possible():
	if jump and is_on_floor():
		state = State.jumping
		$anim.play("jump")
		velocity.y = -move_force.y
		jump = false

func set_wall_normal():
	var offset = Vector2($col.shape.extents.x * 1.5, 0)
	var pos = global_position
	var space = get_world_2d().direct_space_state
	var right_cast = space.intersect_ray(pos, pos + offset, [self])
	# var left_cast = space.intersect_ray(pos, pos - offset, [self])

	wall_normal = Vector2.RIGHT * wall_jump_force.x
	if right_cast:
		wall_normal.x *= -1

func wall_jump():
	if wall_normal.x < 0:
		if right:
			wall_normal.x /= 1.5
		if left:
			wall_normal.x *= 4
	else:
		if right:
			wall_normal.x *= 4
		if left:
			wall_normal.x /= 1.5

	velocity += wall_normal
	velocity.y = -wall_jump_force.y;
	canJump = false
	jump = false
