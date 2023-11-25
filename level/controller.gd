extends Node2D

signal game_over
signal new_game
signal speed_boosted
signal speed_boost_expired

onready var _camera := $Camera2D
onready var _background := $Background
onready var _bird_canvas_layer := $BirdCanvasLayer
onready var _bird := $BirdCanvasLayer/Bird
onready var _obstacle_spawner := $ObstacleSpawner
onready var _death_trigger := $DeathTrigger
onready var _ui := $UICanvasLayer/UI
onready var _speed_boost_timer := $SpeedBoostTimer
onready var _wind_spawner := $EffectsCanvasLayer/WindSpawner

export var bird_scene : PackedScene

var _bird_start_position : Vector2
var _camera_shake_amount := 4.0


func _ready():
	_bird_start_position = _bird.position
	
# warning-ignore:return_value_discarded
	_bird.connect("collided_with_obstacle", self, "_on_bird_collided_with_obstacle")
# warning-ignore:return_value_discarded
	_death_trigger.connect("body_entered", self, "_on_death_trigger_body_entered")
# warning-ignore:return_value_discarded
	_obstacle_spawner.connect("obstacle_spawned", self, "_on_obstacle_spawned")
# warning-ignore:return_value_discarded
	_ui.connect("new_game_pressed", self, "_new_game")
# warning-ignore:return_value_discarded
	_speed_boost_timer.connect("timeout", self, "_on_speed_boost_timer_timeout")
# warning-ignore:return_value_discarded
	_wind_spawner.connect("wind_gust_spawned", self, "_on_wind_gust_spawned")
	
# warning-ignore:return_value_discarded
	connect("speed_boosted", _background, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _bird, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _obstacle_spawner, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _wind_spawner, "start")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _background, "deboost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _bird, "deboost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _ui, "hide_speed_boost_remaining")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _obstacle_spawner, "deboost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _wind_spawner, "stop")
	
# warning-ignore:return_value_discarded
	connect("new_game", _background, "start_scroll")
# warning-ignore:return_value_discarded
	connect("new_game", _bird, "reset")
# warning-ignore:return_value_discarded
	connect("new_game", _obstacle_spawner, "start_timer")
# warning-ignore:return_value_discarded
	connect("new_game", _ui, "on_new_game")
# warning-ignore:return_value_discarded
	connect("new_game", _obstacle_spawner, "deboost_speed")
	
# warning-ignore:return_value_discarded
	connect("game_over", _background, "stop_scroll")
# warning-ignore:return_value_discarded
	connect("game_over", _bird, "die")
# warning-ignore:return_value_discarded
	connect("game_over", _obstacle_spawner, "stop_timer")
# warning-ignore:return_value_discarded
	connect("game_over", _ui, "on_game_over")
	
	randomize()


func _process(_delta):
	if _speed_boost_timer.time_left > 0:
		_ui.set_speed_boost_remaining(round(_speed_boost_timer.time_left))
		_camera.set_offset(Vector2(
			rand_range(-1.0, 1.0) * _camera_shake_amount,
			rand_range(-1.0, 1.0) * _camera_shake_amount
		))


func _on_obstacle_spawned(obstacle):
# warning-ignore:return_value_discarded
	connect("game_over", obstacle, "stop_movement")
# warning-ignore:return_value_discarded
	connect("new_game", obstacle, "queue_free")
# warning-ignore:return_value_discarded
	connect("speed_boosted", obstacle, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", obstacle, "deboost_speed")
	obstacle.connect("speed_boost_gate_entered", self, "_on_speed_boost_gate_entered")
	
	if _speed_boost_timer.time_left > 0:
		obstacle.boost_speed()


func _on_wind_gust_spawned(wind_gust):
# warning-ignore:return_value_discarded
	connect("game_over", wind_gust, "remove")


func _on_speed_boost_gate_entered():
	emit_signal("speed_boosted")
	_speed_boost_timer.start()
	_ui.show_speed_boost_remaining()


func _on_speed_boost_timer_timeout():
	emit_signal("speed_boost_expired")


func _on_bird_collided_with_obstacle(_collision):
	_game_over()


func _on_death_trigger_body_entered(_body):
	_game_over()


func _game_over():
	emit_signal("game_over")
	_speed_boost_timer.stop()
	_background.deboost_speed()


func _new_game():
	emit_signal("new_game")
	_reset_bird()


func _reset_bird():
	if _bird:
		_bird.queue_free()
	
	var new_bird = bird_scene.instance()
	_bird = new_bird
	_bird_canvas_layer.add_child(new_bird)
	_bird.position = _bird_start_position
	
# warning-ignore:return_value_discarded
	_bird.connect("collided_with_obstacle", self, "_on_bird_collided_with_obstacle")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _bird, "boost_speed")
# warning-ignore:return_value_discarded
	connect("game_over", _bird, "die")
