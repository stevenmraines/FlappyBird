extends Node2D

signal game_over
signal new_game
signal speed_boosted
signal speed_boost_expired

onready var _background := $Background
onready var _canvas_layer_1 := $CanvasLayer1
onready var _bird := $CanvasLayer1/Bird
onready var _obstacle_spawner := $ObstacleSpawner
onready var _death_trigger := $DeathTrigger
onready var _ui := $CanvasLayer2/UI
onready var _speed_boost_timer := $SpeedBoostTimer

export var bird_scene : PackedScene

var _bird_start_position : Vector2


func _ready():
	_bird_start_position = _bird.position
	
# warning-ignore:return_value_discarded
	_bird.connect("body_entered", self, "_on_body_entered")
# warning-ignore:return_value_discarded
	_death_trigger.connect("body_entered", self, "_on_body_entered")
# warning-ignore:return_value_discarded
	_obstacle_spawner.connect("obstacle_spawned", self, "_on_obstacle_spawned")
# warning-ignore:return_value_discarded
	_ui.connect("new_game_pressed", self, "_new_game")
# warning-ignore:return_value_discarded
	_speed_boost_timer.connect("timeout", self, "_on_speed_boost_timer_timeout")
	
# warning-ignore:return_value_discarded
	connect("speed_boosted", _background, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _bird, "boost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _background, "deboost_speed")
# warning-ignore:return_value_discarded
	connect("speed_boost_expired", _bird, "deboost_speed")
	
# warning-ignore:return_value_discarded
	connect("new_game", _background, "start_scroll")
# warning-ignore:return_value_discarded
	connect("new_game", _bird, "reset")
# warning-ignore:return_value_discarded
	connect("new_game", _obstacle_spawner, "start_timer")
# warning-ignore:return_value_discarded
	connect("new_game", _ui, "on_new_game")
	
# warning-ignore:return_value_discarded
	connect("game_over", _background, "stop_scroll")
# warning-ignore:return_value_discarded
	connect("game_over", _bird, "stop_input")
# warning-ignore:return_value_discarded
	connect("game_over", _obstacle_spawner, "stop_timer")
# warning-ignore:return_value_discarded
	connect("game_over", _ui, "on_game_over")
	
	randomize()


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


func _on_speed_boost_gate_entered():
	emit_signal("speed_boosted")
	_speed_boost_timer.start()


func _on_speed_boost_timer_timeout():
	emit_signal("speed_boost_expired")


func _on_body_entered(_body):
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
	_canvas_layer_1.add_child(new_bird)
	_bird.position = _bird_start_position
# warning-ignore:return_value_discarded
	_bird.connect("body_entered", self, "_on_body_entered")
# warning-ignore:return_value_discarded
	connect("speed_boosted", _bird, "boost_speed")
# warning-ignore:return_value_discarded
	connect("game_over", _bird, "stop_input")
