extends Node2D

signal smash_gate_entered

onready var _smash_icon_animator := $SmashIconAnimator
onready var _area_2d := $Area2D

export var smash_icon_animation : Animation


func _ready():
	_smash_icon_animator.add_animation("smash_icon", smash_icon_animation)
	_smash_icon_animator.play("smash_icon")
# warning-ignore:return_value_discarded
	_area_2d.connect("body_entered", self, "_on_area_2d_body_entered")
	deactivate()


func _on_area_2d_body_entered(_body):
	emit_signal("smash_gate_entered")


func activate():
	visible = true
	_area_2d.monitoring = true
	_area_2d.monitorable = true


func deactivate():
	visible = false
	_area_2d.monitoring = false
	_area_2d.monitorable = false
