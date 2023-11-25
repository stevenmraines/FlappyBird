extends CanvasLayer

signal position_timer_timeout(ghost)

onready var _sprite := $Sprite
onready var _position_timer := $PositionTimer

# TODO Use Path2D and PathFollow2D instead
func _ready():
# warning-ignore:return_value_discarded
	_position_timer.connect("timeout", self, "_on_position_timer_timeout")


func set_alpha(alpha):
	_sprite.modulate.a = alpha


func set_position(position):
	_sprite.position = position


func get_position():
	return _sprite.position


func set_is_visible(visible):
	_sprite.visible = visible


func _on_position_timer_timeout():
	emit_signal("position_timer_timeout", self)


func set_position_timer_wait_time(wait_time):
	_position_timer.wait_time = wait_time


func start_position_timer():
	_position_timer.start()
