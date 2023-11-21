extends Control

signal new_game_pressed

onready var _score := $Score
onready var _game_over_message := $GameOverMessage
onready var _new_game_button := $NewGameButton

var _time_start := 0
var _time_now := 0
var _update_time := true


func _ready():
	_time_start = OS.get_unix_time()
# warning-ignore:return_value_discarded
	_new_game_button.connect("button_up", self, "_emit_new_game_signal")


func _process(_delta):
	if not _update_time:
		return
		
	_time_now = OS.get_unix_time()
	$Score.text = str(_time_now - _time_start, "s")


func _stop_timer():
	_update_time = false


func _reset_timer():
	_update_time = true
	_time_start = OS.get_unix_time()
	_time_now = 0


func _show_game_over():
	_game_over_message.visible = true
	_new_game_button.visible = true


func _hide_game_over():
	_game_over_message.visible = false
	_new_game_button.visible = false


func _emit_new_game_signal():
	emit_signal("new_game_pressed")


func on_new_game():
	_reset_timer()
	_hide_game_over()


func on_game_over():
	_stop_timer()
	_show_game_over()
