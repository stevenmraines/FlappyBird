extends Node2D

signal wind_spawn_timer_stopped

export var wind_effect_scene : PackedScene
export var gusts_per_second := 3
export var min_alpha := 0.3
export var max_alpha := 0.7

var _spawn_timer : Timer
var _screen_width := 1024
var _screen_height := 600


func _ready():
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.wait_time = 1.0 / gusts_per_second
# warning-ignore:return_value_discarded
	_spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")
	add_child(_spawn_timer)


func _on_spawn_timer_timeout():
	for _i in range(0, gusts_per_second):
		var new_gust := wind_effect_scene.instance()
# warning-ignore:return_value_discarded
		connect("wind_spawn_timer_stopped", new_gust, "queue_free")
		add_child(new_gust)
		new_gust.position = Vector2(
			rand_range(0, _screen_width),
			rand_range(0, _screen_height)
		)
		new_gust.scale = Vector2(0.2, 0.05)
		new_gust.set_alpha(rand_range(min_alpha, max_alpha))


func start():
	_spawn_timer.start()


func stop():
	_spawn_timer.stop()
	emit_signal("wind_spawn_timer_stopped")
