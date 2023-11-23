extends Node2D

signal smash_gate_entered
signal speed_boost_gate_entered
signal slide_gate_entered
signal moved_past_screen_edge(obstacle)

onready var _pipe_animator := $PipeAnimator
onready var _smash_gate := $SmashGate
onready var _speed_boost_gate := $SpeedBoostGate
onready var _slide_gate := $SlideGate
onready var _slide_tweener := $SlideTweener

export var smash_animation : Animation
export var movement_speed := 200
export var boosted_movement_speed := 400
export var slide_duration := 2

enum obstacle_types {
	Regular=0,
	Smash=1,
	Boost=2,
	Slide=3
}

var _move_obstacle := true
var _obstacle_type = obstacle_types.Regular
var _is_speed_boosted := false
var _last_slide_position := 0

const SLIDE_TOP := -160
const SLIDE_BOTTOM := 140


func _ready():
	_pipe_animator.add_animation("smash", smash_animation)
	
# warning-ignore:return_value_discarded
	_smash_gate.connect("smash_gate_entered", self, "_on_smash_gate_entered")
# warning-ignore:return_value_discarded
	_speed_boost_gate.connect("speed_boost_gate_entered", self, "_on_speed_boost_gate_entered")
# warning-ignore:return_value_discarded
	_slide_gate.connect("slide_gate_entered", self, "_on_slide_gate_entered")
# warning-ignore:return_value_discarded
	_slide_tweener.connect("tween_completed", self, "_on_slide_tweener_tween_completed")


func _physics_process(delta):
	if not _move_obstacle:
		return
	
	position.x = position.x - _get_movement_speed() * delta
	
	if global_position.x < -115:
		emit_signal("moved_past_screen_edge", self)


func _on_smash_gate_entered():
	emit_signal("smash_gate_entered")


func _on_speed_boost_gate_entered():
	emit_signal("speed_boost_gate_entered")


func _on_slide_gate_entered():
	emit_signal("slide_gate_entered")


func _on_slide_tweener_tween_completed(_object, _key):
	_slide_lerp(SLIDE_BOTTOM if _last_slide_position == SLIDE_TOP else SLIDE_TOP)


func _get_movement_speed():
	if _is_speed_boosted:
		return boosted_movement_speed
	else:
		return movement_speed


func stop_movement():
	_move_obstacle = false
	_slide_tweener.stop_all()


func play_smash_animation():
	if _obstacle_type == obstacle_types.Regular:
		_pipe_animator.play("smash")
		return true
	return false


func play_slide_animation(direction):
	if _obstacle_type == obstacle_types.Regular:
		_slide_lerp(SLIDE_TOP if direction == "top" else SLIDE_BOTTOM)
		return true
	return false


func _slide_lerp(y):
	_last_slide_position = y
	
	var distance_to_new_position := abs(y - position.y)
	var full_distance := abs(SLIDE_TOP) + abs(SLIDE_BOTTOM)
	var percent_of_full_distance := distance_to_new_position / full_distance
	var duration = slide_duration * percent_of_full_distance
	
	_slide_tweener.interpolate_property(
		self,
		"position:y",
		position.y,
		y,
		duration,
		Tween.TRANS_LINEAR
	)
	
	_slide_tweener.start()


func make_regular_type():
	_set_obstacle_type(obstacle_types.Regular)


func make_smash_type():
	_set_obstacle_type(obstacle_types.Smash)


func make_boost_type():
	_set_obstacle_type(obstacle_types.Boost)


func make_slide_type():
	_set_obstacle_type(obstacle_types.Slide)


func _set_obstacle_type(type):
	_obstacle_type = type
	
	_smash_gate.deactivate()
	_speed_boost_gate.deactivate()
	_slide_gate.deactivate()
	
	if type == obstacle_types.Smash:
		_smash_gate.activate()
	elif type == obstacle_types.Boost:
		_speed_boost_gate.activate()
	elif type == obstacle_types.Slide:
		_slide_gate.activate()


func boost_speed():
	_is_speed_boosted = true


func deboost_speed():
	_is_speed_boosted = false
