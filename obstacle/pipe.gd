tool
extends RigidBody2D

onready var _texture_rect := $TextureRect

export var flipped := false setget _set_flipped


func _ready():
	_update_texture_rect()


func _set_flipped(value):
	flipped = value
	_update_texture_rect()


func _update_texture_rect():
	if not _texture_rect:
		_texture_rect = get_node("TextureRect")
	_texture_rect.flip_v = flipped
