extends RigidBody2D

export var vertical_movement_speed := 100
export var horizontal_movement_speed := 100
export var _speed_boost_ghost_scene : PackedScene
export var number_of_speed_ghosts := 4
export var speed_ghost_delay_modifier := 6.0

onready var _input_timer := $InputTimer
onready var _animated_sprite := $AnimatedSprite

var _up_arrow_key_pressed := false
var _allow_input := true
var _needs_reset := false
var _is_speed_boosted := false
var _speed_ghosts : Array


func _ready():
# warning-ignore:return_value_discarded
	_input_timer.connect("timeout", self, "_on_input_timer_timeout")
	
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


func _integrate_forces(state):
	if _needs_reset:
		_allow_input = true
#		set_axis_velocity(Vector2())
#		state.set_transform(Transform2D(0.0, Vector2(256, 300)))
#		state.set_transform(state.get_transform().rotated(0))
#		state.transform = Transform2D(0.0, Vector2(256, 300))
		
#		set_axis_velocity(Vector2.ZERO)  # Reset velocity to zero
		state.set_angular_velocity(0)
		state.set_linear_velocity(Vector2.ZERO)
		state.transform.origin = Vector2(256, 300)  # Reset position
		state.transform = state.transform.rotated(-state.transform.get_rotation())
		_needs_reset = false
	
	if not _allow_input:
		return
	
	var velocity = Vector2.ZERO
	var _key_pressed := false
	
	if Input.is_key_pressed(KEY_UP):
		velocity.y = -vertical_movement_speed
		_up_arrow_key_pressed = true
		_key_pressed = true
	elif _up_arrow_key_pressed:
		_up_arrow_key_pressed = false
		_key_pressed = true
	
	if Input.is_key_pressed(KEY_RIGHT):
		velocity.x = horizontal_movement_speed
		_key_pressed = true
	elif Input.is_key_pressed(KEY_LEFT):
		velocity.x = -horizontal_movement_speed
		_key_pressed = true
	
	set_axis_velocity(velocity)
#	state.apply_central_impulse(velocity)
	
#	if _key_pressed:
#		_input_timer.start()
#		_allow_input = false


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


func _on_input_timer_timeout():
	_allow_input = true


func stop_input():
	_allow_input = false
	_set_speed_ghosts_visibility(false)


func reset():
	_needs_reset = true
	_animated_sprite.play()


func boost_speed():
	_is_speed_boosted = true
	_animated_sprite.stop()
	_animated_sprite.frame = 1
	_set_speed_ghosts_visibility(true)


func deboost_speed():
	_is_speed_boosted = false
	_animated_sprite.play()
	_set_speed_ghosts_visibility(false)


func _set_speed_ghosts_visibility(visible):
	for ghost in _speed_ghosts:
		ghost.set_is_visible(visible)
