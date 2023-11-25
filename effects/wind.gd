extends Line2D

export var speed := 200

onready var _path_follow_2d := $Path2D/PathFollow2D
onready var _sprite := $Path2D/PathFollow2D/Sprite
onready var _visibility_notifier_2d := $VisibilityNotifier2D
onready var _path_offset_timer := $PathOffsetTimer


func _ready():
# warning-ignore:return_value_discarded
	_visibility_notifier_2d.connect("screen_exited", self, "_on_screen_exited")
# warning-ignore:return_value_discarded
	_path_offset_timer.connect("timeout", self, "queue_free")


func _process(delta):
	position.x -= speed * delta
	var time_passed = _path_offset_timer.wait_time - _path_offset_timer.time_left
	_path_follow_2d.set_unit_offset(time_passed / _path_offset_timer.wait_time)


func _on_screen_exited():
	queue_free()


func set_alpha(alpha):
	_sprite.modulate.a = alpha
