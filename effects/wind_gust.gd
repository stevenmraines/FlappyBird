extends Line2D

export var path_flip_h = false
export var reverse_path_traversal = false
export var line_segments = 20
export var trail_length = 1.0
export var trail_speed = 0.001
export var movement_speed = 200
export var random_y_offset = 0.0
export var trail_color_gradient : Gradient

onready var _path_2d := $Path2D
onready var _visibility_notifier_2d := $VisibilityNotifier2D

var pf_dict = []
var use_gradient = false


func _ready():
	_initialize_path()


func _initialize_path():
	if path_flip_h:
		flip_path()
	
	if random_y_offset > 0.0:
		randomize_path()
	
	init_path_followers()
	
	if trail_color_gradient != null:
		use_gradient = true
	
	if reverse_path_traversal:
		for pf in pf_dict:
			pf.unit_offset = 1.0
	
# warning-ignore:return_value_discarded
	_visibility_notifier_2d.connect("screen_exited", self, "remove")


func _process(delta):
	position.x = position.x - movement_speed * delta
	
	move_path()
	
	if use_gradient:
		update_path_gradient()
	
	draw_path()


func flip_path():
	var point_pos = []
	var point_in = []
	var point_out = []
	
	var curve_points = _path_2d.curve.get_point_count()
	
	for i in range(0, curve_points):
		point_pos.append(_path_2d.curve.get_point_position(i))
		point_in.append(_path_2d.curve.get_point_in(i))
		point_out.append(_path_2d.curve.get_point_out(i))
	
	_path_2d.curve.clear_points()
	
	var j = 0
	for i in range(curve_points - 1, -1, -1):
		_path_2d.curve.add_point(point_pos[i], -point_in[i], -point_out[i], j)
		j += 1


func move_path():
	for pf in pf_dict:
		pf.trail_offset += trail_speed
		if pf.trail_offset >= 0.0 and pf.trail_offset <= 1.0:
			pf.unit_offset = pf.trail_offset
		
		if pf.trail_offset >= 1.0:
			pf.unit_offset = 1.0
	
	var completed_offset = 0.0 if reverse_path_traversal else 1.0
	if pf_dict[0].unit_offset == completed_offset:
		remove()


func update_path_gradient():
	for pcnt in range(line_segments + 1):
		gradient.colors[pcnt] = trail_color_gradient.interpolate(gradient.offsets[pcnt])
		gradient.colors[pcnt].a *= trail_color_gradient.interpolate(pf_dict[pcnt].unit_offset).a


func randomize_path():
	randomize()
	var rng = RandomNumberGenerator.new()
	
	for i in range(_path_2d.curve.get_point_count()):
		var curve_point = _path_2d.curve.get_point_position(i)
		curve_point.y += rng.randf_range(-random_y_offset, random_y_offset)
		_path_2d.curve.set_point_position(i, curve_point)


func draw_path():
	clear_points()
	
	for pf in pf_dict:
		add_point(pf.global_position)


func init_path_followers():
	for pf_cnt in range(line_segments + 1):
		var new_pf = TrailFollow2D.new()
		_path_2d.add_child(new_pf)
		new_pf.trail_offset = float(pf_cnt) / float(line_segments) * trail_length - trail_length
		new_pf.loop = false
		pf_dict.append(new_pf)
	
	gradient = Gradient.new()
	gradient.remove_point(0)

	for g_cnt in range(line_segments):
		gradient.add_point(float(g_cnt + 1) / float(line_segments), Color(1.0, 1.0, 1.0, 1.0))


func remove():
	queue_free()
