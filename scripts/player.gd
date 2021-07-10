extends KinematicBody2D

export var move_force: Vector2
export var air_control_ratio: float
export var wall_jump_force: Vector2
export var gravity: float
export var acc_grav: float
export var friction: float
export var air_friction: float
export var wall_friction: float
export var wall_hold_time: float
export var jump_hold_time: float

export var start_delay: float = 1

export var jump_sound: AudioStream
export var wall_jump_sound: AudioStream

var velocity: Vector2

var wall_normal: Vector2
var wall_detach_timer: float = 0

var jump_hold: bool = false
var time_jump_released = 0

var grounded: bool = false
var canJump: bool = false
var right: bool = false
var left: bool = false
var jump: bool = false

var started: bool = false
var start_time: float = 0

enum State {idle, running, wall, jumping}
var state = State.idle

func _ready():
	$anim.animation_set_next("run start", "run")
	$anim.animation_set_next("land", "idle")
	$anim.animation_set_next("into wall slide", "wall slide")
	start_delay *= 1000
	pass

func _physics_process(delta):
	if !started:
		return

	check_ground()
	hold_jump_input()
	match state:
		State.idle:
			apply_run_force(delta)
			jump_if_possible()
			if right or left:
				start_run()
		State.running:
			apply_run_force(delta)
			jump_if_possible()
			if !right and !left:
				$anim.play("idle")
				state = State.idle
		State.wall:
			if detach_from_wall(delta):
				velocity.x -= wall_normal.x * .1
			if !is_on_wall():
				state = State.jumping
			if velocity.y > 0:
				velocity.y *= 1 - wall_friction * delta
			if grounded:
				$anim.play("idle")
				$landing_sfx.play()
				state = State.idle
			else:
				wall_jump()
		State.jumping:
			apply_air_control(delta)
			if grounded and velocity.y >= 0:
				$anim.play("land")
				$landing_sfx.play()
				state = State.idle
			if !grounded and is_on_wall():
				$anim.play("into wall slide")
				set_wall_normal()
				velocity.x -= wall_normal.x
				if velocity.y > 0:
					velocity.y /= 8
				canJump = true
	
	velocity.y += gravity * delta
	velocity.y += abs(velocity.y) * acc_grav * delta
	
	if velocity.y > move_force.y * 2:
		velocity.y = move_force.y * 2

	velocity = move_and_slide(velocity, Vector2.UP)

func _input(event):
	if event.is_action_pressed("ui_right"):
		right = true
		start()
	if event.is_action_pressed("ui_left"):
		left = true
		start()
	if event.is_action_pressed("ui_up"):
		jump = true
		jump_hold = false
		time_jump_released = OS.get_ticks_msec()
		start()

	if event.is_action_released("ui_right"):
		right = false
	if event.is_action_released("ui_left"):
		left = false
	if event.is_action_released("ui_up"):
		jump_hold = true
		time_jump_released = OS.get_ticks_msec()


func apply_run_force(delta):
	velocity.x *= 1 - friction * delta
	if right:
		$sprite.flip_h = false
		velocity.x += move_force.x
	if left:
		$sprite.flip_h = true
		velocity.x -= move_force.x

func start_run():
	$anim.play("run start")
	if velocity.x > 0:
		velocity.x = move_force.x * 3
	else:
		velocity.x = -move_force.x * 3
	state = State.running


func apply_air_control(delta):
	velocity.x *= 1 - air_friction * delta
	if right:
		$sprite.flip_h = false
		velocity.x += move_force.x * air_control_ratio
	if left:
		$sprite.flip_h = true
		velocity.x -= move_force.x * air_control_ratio

func jump_if_possible():
	if jump and is_on_floor():
		state = State.jumping
		$anim.play("jump")
		velocity.y = -move_force.y
		$sfx.stream = jump_sound
		$sfx.play()
		jump = false

func set_wall_normal():
	$landing_sfx.play()

	var dir = Vector2($col.shape.radius * 2, 0)
	var offset = Vector2(0, $col.shape.height)
	var pos = global_position
	var space = get_world_2d().direct_space_state
	var right_cast = space.intersect_ray(pos, pos + dir, [self])
	if !right_cast:
		pos += offset
		right_cast = space.intersect_ray(pos, pos + dir, [self])
	if !right_cast:
		pos -= offset * 2
		right_cast = space.intersect_ray(pos, pos + dir, [self])

	# var left_cast = space.intersect_ray(pos, pos - offset, [self])

	wall_normal = Vector2.RIGHT * wall_jump_force.x
	if right_cast:
		wall_normal.x *= -1
	state = State.wall

func wall_jump():
	if !jump || !canJump:
		return

	state = State.jumping
	var y_vel = -wall_jump_force.y;
	if wall_normal.x < 0:
		# if left:
		# 	wall_normal.x *= 1.5
		# 	y_vel *= .75
		if right:
			y_vel *= .6
	else:
		# if right:
		# 	wall_normal.x *= 1.5
		# 	y_vel *= .75
		if left:
			y_vel *= .6

	velocity += wall_normal
	velocity.y = y_vel

	$sfx.stream = wall_jump_sound
	$sfx.play()
	$anim.play("wall jump")
	canJump = false
	jump = false

func detach_from_wall(delta):
	if wall_normal.x < 0 and left:
		wall_detach_timer += delta
	elif wall_normal.x > 0 and right:
		wall_detach_timer += delta
	else:
		wall_detach_timer = 0

	if wall_detach_timer > wall_hold_time:
		state = State.jumping
		return false
	return true

func hold_jump_input():
	if !jump_hold || !jump:
		return
	
	if OS.get_system_time_msecs() > time_jump_released + jump_hold_time:
		jump_hold = false
		jump = false

func check_ground():
	grounded = false
	var offset = Vector2(0, $col.shape.radius + $col.shape.height * 1.25)
	var pos = global_position
	var space = get_world_2d().direct_space_state
	var right_cast = space.intersect_ray(pos, pos + offset, [self])
	if right_cast:
		grounded = true

func start():
	if start_time == 0:
		start_time = OS.get_ticks_msec()
	if started || OS.get_ticks_msec() < start_time + start_delay:
		return
	started = true
	$start_filter.queue_free()
