extends ParallaxBackground

export var scroll_speed := 30
export var boosted_scroll_speed := 60

onready var _parallax_layer := $ParallaxLayer

var _scroll_background := true
var _is_speed_boosted := false


func _process(delta):
	if not _scroll_background:
		return
	
	var x = $ParallaxLayer.motion_offset.x
	$ParallaxLayer.set_motion_offset(Vector2(x - _get_scroll_speed() * delta, 0))


func stop_scroll():
	_scroll_background = false


func start_scroll():
	_scroll_background = true


func _get_scroll_speed():
	if _is_speed_boosted:
		return boosted_scroll_speed
	else:
		return scroll_speed


func boost_speed():
	_is_speed_boosted = true


func deboost_speed():
	_is_speed_boosted = false
