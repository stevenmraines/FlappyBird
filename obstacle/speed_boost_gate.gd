extends Node2D

signal speed_boost_gate_entered

onready var _area_2d := $Area2D
onready var _speed_boost_icon := $SpeedBoostIcon
onready var _tween := $Tween


func _ready():
# warning-ignore:return_value_discarded
	_area_2d.connect("body_entered", self, "_on_area_2d_body_entered")
	
	_tween.interpolate_property(
		_speed_boost_icon,
		"modulate",
		Color(1,1,1,0.25),
		Color(1,1,1,1),
		1.5
	)
	
	_tween.start()
	
	deactivate()


func _on_area_2d_body_entered(_body):
	emit_signal("speed_boost_gate_entered")


func activate():
	visible = true
	_area_2d.monitoring = true
	_area_2d.monitorable = true


func deactivate():
	visible = false
	_area_2d.monitoring = false
	_area_2d.monitorable = false
