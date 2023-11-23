extends Node2D

signal slide_gate_entered

onready var _area_2d := $Area2D
onready var _slide_icon_animator := $SlideIconAnimator

export var slide_icon_animation : Animation

func _ready():
	_slide_icon_animator.add_animation("slide_icon", slide_icon_animation)
	_slide_icon_animator.play("slide_icon")
# warning-ignore:return_value_discarded
	_area_2d.connect("body_entered", self, "_on_area_2d_body_entered")
	deactivate()


func _on_area_2d_body_entered(_body):
	emit_signal("slide_gate_entered")


func activate():
	visible = true
	_area_2d.monitoring = true
	_area_2d.monitorable = true


func deactivate():
	visible = false
	_area_2d.monitoring = false
	_area_2d.monitorable = false
