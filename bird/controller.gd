extends KinematicBody2D

signal collided_with_obstacle(collision)

export var gravity := 1000
export var max_velocity := 600
export var flap_speed := -500

# TODO Exporting this var breaks it for some reason, value can't be changed in inspector
var vertical_movement_speed := 400
export var dash_distance := 100
export var stall_duration := 0.4
export var dash_duration := 0.3
export var _speed_boost_ghost_scene : PackedScene
export var number_of_speed_ghosts := 4
export var speed_ghost_delay_modifier := 6.0

onready var _animated_sprite := $AnimatedSprite
onready var _dash_tweener := $DashTweener
onready var _speed_boost_reset_tweener := $SpeedBoostResetTweener

var _initial_position : Vector2
var _up_arrow_key_pressed := false
var _allow_input := true
var _needs_reset := false
var _is_speed_boosted := false
var _speed_ghosts : Array
var _can_dash := true
var _velocity := Vector2.ZERO
var _is_flying := false
var _is_dead := false
var _is_landed_on_pipe := false
var _touched_bottom_of_top_pipe := false


func _ready():
	_initial_position = position
	
# warning-ignore:return_value_discarded
	_dash_tweener.connect("tween_completed", self, "_on_dash_tweener_tween_completed")
	
	for i in range(1, number_of_speed_ghosts + 1):
		var ghost = _speed_boost_ghost_scene.instance()
		add_child(ghost)
		ghost.set_alpha(1.0 / i + 0.2)
		var x = _animated_sprite.global_position.x - 30 * i
		var y = _animated_sprite.global_position.y
		ghost.set_position(Vector2(x, y))
		ghost.set_position_timer_wait_time(i / (speed_ghost_delay_modifier / 1.0))
		ghost.connect("position_timer_timeout", self, "_set_speed_ghost_position")
		_speed_ghosts.append(ghost)
		ghost.start_position_timer()


# TODO Clean up all this mess later, try to separate movement, animation, rotation, and state as much as possible
func _physics_process(delta):
	if _is_dead and not _is_landed_on_pipe and not _touched_bottom_of_top_pipe:
		_velocity.y += gravity * delta
		_velocity.y = min(_velocity.y, max_velocity)
		_animated_sprite.stop()
		var collision := move_and_collide(_velocity * delta)
		var angle := PI / 2
		if collision:
			if collision.get_normal() == Vector2(0, 1):
				_velocity.y = gravity * delta
				_touched_bottom_of_top_pipe = true
			if collision.get_normal() == Vector2(0, -1):
				angle = 0
				_is_landed_on_pipe = true
		set_rotation(angle)
		return
	
	var collision : KinematicCollision2D
	
	if _is_speed_boosted:
		_velocity.y = 0
		set_rotation(deg2rad(0))
		
		if Input.is_key_pressed(KEY_UP):
			_velocity.y = flap_speed
		elif Input.is_key_pressed(KEY_DOWN):
			_velocity.y = -flap_speed
			
		collision = move_and_collide(_velocity * delta)
	else:
		_is_flying = Input.is_key_pressed(KEY_UP) and _allow_input
		
		if _is_flying:
			_velocity.y = flap_speed
			_play_flying_animation()
		else:
			_velocity.y += gravity * delta
			_animated_sprite.stop()
		
		if _allow_input and _can_dash and Input.is_key_pressed(KEY_LEFT):
			_play_stall_animation()
			_do_dash(position.x - dash_distance)
			set_rotation(deg2rad(0))
			_velocity.y = 0
		elif _allow_input and _can_dash and Input.is_key_pressed(KEY_RIGHT):
			_play_dash_animation()
			_do_dash(position.x + dash_distance)
			set_rotation(deg2rad(0))
			_velocity.y = 0
		
		_velocity.y = min(_velocity.y, max_velocity)
		set_rotation(deg2rad(_velocity.y * 0.05))
		collision = move_and_collide(_velocity * delta)
	
	if collision:
		emit_signal("collided_with_obstacle", collision)


func _do_dash(new_x):
	_can_dash = false
	
	_dash_tweener.interpolate_property(
		self,
		"position",
		position,
		Vector2(new_x, position.y),
		dash_duration if new_x > position.x else stall_duration,
		Tween.TRANS_QUAD if new_x > position.x else Tween.TRANS_LINEAR
	)
	
	_dash_tweener.start()


func _on_dash_tweener_tween_completed(_object, _key):
	_can_dash = true
	_play_flying_animation()


func _set_speed_ghost_position(ghost):
	var previous_ghost_position_y = _animated_sprite.global_position.y
	for i in range(0, number_of_speed_ghosts):
		if _speed_ghosts[i] == ghost:
			var x = _animated_sprite.global_position.x - 30 * i
			var y = previous_ghost_position_y
			_speed_ghosts[i].set_position(Vector2(x, y))
			return
		else:
			previous_ghost_position_y = _speed_ghosts[i].get_position().y


func die():
	_allow_input = false
	_set_speed_ghosts_visibility(false)
	_is_flying = false
	_is_dead = true


func reset():
	_needs_reset = true
	_play_flying_animation()
	_can_dash = true
	_is_flying = false
	_is_dead = false


func boost_speed():
	_is_speed_boosted = true
	_play_speed_boost_animation()
	_is_flying = false
	_can_dash = false
	
	_speed_boost_reset_tweener.interpolate_property(
		self,
		"position:x",
		position.x,
		_initial_position.x,
		1.0,
		Tween.TRANS_LINEAR
	)
	
	_speed_boost_reset_tweener.start()


func deboost_speed():
	_is_speed_boosted = false
	_play_flying_animation()
	_can_dash = true


func _set_speed_ghosts_visibility(visible):
	for ghost in _speed_ghosts:
		ghost.set_is_visible(visible)


func _play_flying_animation():
	_animated_sprite.play("flying")
	_set_speed_ghosts_visibility(false)


func _play_stall_animation():
	_animated_sprite.play("stall")
	_set_speed_ghosts_visibility(false)


func _play_speed_boost_animation():
	_animated_sprite.stop()
	_animated_sprite.frame = 1
	_set_speed_ghosts_visibility(true)


func _play_dash_animation():
	_animated_sprite.play("dash")
	_set_speed_ghosts_visibility(false)
