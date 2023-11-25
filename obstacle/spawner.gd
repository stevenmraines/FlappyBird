extends Node2D

signal obstacle_spawned(obstacle)

onready var _spawn_timer := $SpawnTimer

export var obstacle_scene : PackedScene
# TODO These exported vars stopped working as well...
var speed_boost_spawn_index := 1
var smash_spawn_index := 10
var slide_spawn_index := 33
export var max_smashers := 3
export var max_sliders := 3
export var min_y := -200
export var max_y := 400
export var spawn_timer_wait_time := 2.5
export var spawn_timer_speed_boosted_wait_time := 1.5

var _spawn_counter := 0
var _smashers_remaining := 0
var _sliders_remaining := 0
var _last_slide_position : String
var _spawned_obstacles : Dictionary


func _ready():
# warning-ignore:return_value_discarded
	_spawn_timer.connect("timeout", self, "_spawn_obstacle")


func _spawn_obstacle():
	_spawn_counter += 1
	
	var new_obstacle = obstacle_scene.instance()
	add_child(new_obstacle)
	_spawned_obstacles[new_obstacle.get_instance_id()] = new_obstacle
	new_obstacle.position.y = rand_range(min_y, max_y)
	new_obstacle.connect("moved_past_screen_edge", self, "_on_obstacle_moved_past_screen_edge")
	new_obstacle.connect("smash_gate_entered", self, "_on_smash_gate_entered")
	new_obstacle.connect("slide_gate_entered", self, "_on_slide_gate_entered")
	emit_signal("obstacle_spawned", new_obstacle)
	
	if _spawn_counter == speed_boost_spawn_index:
		new_obstacle.make_boost_type()
	elif _spawn_counter == smash_spawn_index:
		new_obstacle.make_smash_type()
	elif _spawn_counter == slide_spawn_index:
		new_obstacle.make_slide_type()
	elif _smashers_remaining > 0:
		new_obstacle.play_smash_animation()
		_smashers_remaining -= 1
	elif _sliders_remaining > 0:
		new_obstacle.play_slide_animation(_get_next_slide_position())
		_sliders_remaining -= 1
	
	if _spawn_counter == 20:
		_spawn_counter = 0


func _on_obstacle_moved_past_screen_edge(obstacle):
# warning-ignore:return_value_discarded
	_spawned_obstacles.erase(obstacle.get_instance_id())
	obstacle.queue_free()


func _on_smash_gate_entered():
	_smashers_remaining = max_smashers
	
	for instance_id in _spawned_obstacles:
		var obstacle = _spawned_obstacles[instance_id]
		if obstacle.play_smash_animation():
			_smashers_remaining -= 1


func _on_slide_gate_entered():
	_sliders_remaining = max_sliders
	
	for instance_id in _spawned_obstacles:
		var obstacle = _spawned_obstacles[instance_id]
		if obstacle.play_slide_animation(_get_next_slide_position()):
			_sliders_remaining -= 1


func _get_next_slide_position():
	if _last_slide_position == null or _last_slide_position == "bottom":
		_last_slide_position = "top"
		return "top"
	else:
		_last_slide_position = "bottom"
		return "bottom"


func start_timer():
	_spawn_timer.start()


func stop_timer():
	_spawn_timer.stop()
	_spawn_counter = 0
	_smashers_remaining = 0
	_sliders_remaining = 0
	_spawned_obstacles = {}


func boost_speed():
	_spawn_timer.wait_time = spawn_timer_speed_boosted_wait_time


func deboost_speed():
	_spawn_timer.wait_time = spawn_timer_wait_time
