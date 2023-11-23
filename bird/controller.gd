extends RigidBody2D

export var max_velocity := 600
export var gravity := 100
export var hang_time := 100.0
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

var _up_arrow_key_pressed := false
var _allow_input := true
var _needs_reset := false
var _is_speed_boosted := false
var _speed_ghosts : Array
var _downward_velocity := 0
var _time_hung := 0.0
var _can_dash := true


func _ready():
# warning-ignore:return_value_discarded
	_dash_tweener.connect("tween_completed", self, "_on_dash_tweener_tween_completed")
	
	_play_flying_animation()
	
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


func _physics_process(delta):
	var new_y = position.y + _downward_velocity
	
	if Input.is_key_pressed(KEY_UP):
		new_y = position.y - vertical_movement_speed * delta
		_downward_velocity = 0
		_time_hung = 0
	elif _is_speed_boosted and Input.is_key_pressed(KEY_DOWN):
		new_y = position.y + vertical_movement_speed * delta
		_downward_velocity = 0
		_time_hung = 0
	elif not _is_speed_boosted and _time_hung >= hang_time:
# warning-ignore:narrowing_conversion
		_downward_velocity = clamp(_downward_velocity + delta * gravity, 0, max_velocity)
	else:
		_time_hung += delta
	
	if _can_dash and Input.is_key_pressed(KEY_LEFT):
		_play_stall_animation()
		_do_dash(position.x - dash_distance)
	elif _can_dash and Input.is_key_pressed(KEY_RIGHT):
		_play_dash_animation()
		_do_dash(position.x + dash_distance)
		
	position.y = new_y


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


func stop_input():
	_allow_input = false
	_set_speed_ghosts_visibility(false)


func reset():
	_needs_reset = true
	_play_flying_animation()
	_time_hung = 0.0
	_can_dash = true


func boost_speed():
	_is_speed_boosted = true
	_play_speed_boost_animation()
	_can_dash = false


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
