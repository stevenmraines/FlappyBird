# The root Line2D is used to actually draw the trail of path followers
extends Line2D

export var flip_h = false
export var line_segments = 20
export var trail_spacing = 1.0
export var trail_speed = 0.001
export var movement_speed = 200
export var random_y_offset = 0.0
export var trail_color_gradient : Gradient

onready var _path_2d := $Path2D
onready var _visibility_notifier_2d := $VisibilityNotifier2D

var trail_followers = []
var use_gradient = false


func _ready():
	if flip_h:
		flip_path()
	
	if random_y_offset > 0.0:
		randomize_path()
	
	init_trail_followers_and_gradient()
	
	if trail_color_gradient != null:
		use_gradient = true
	
#	if flip_h:
#		for follower in trail_followers:
#			follower.unit_offset = 1.0
	
# warning-ignore:return_value_discarded
	_visibility_notifier_2d.connect("screen_exited", self, "remove")


func _process(delta):
	position.x = position.x - movement_speed * delta
	
	move_trail_followers()
	
	if use_gradient:
		update_line_gradient()
	
	update_line_points()


func flip_path():
	# The position of the path point
	var point_pos = []
	# The left curve control handle of the point
	var point_in = []
	# The right curve control handle of the point
	var point_out = []
	
	var path_point_count = _path_2d.curve.get_point_count()
	
	# Back up the path points before clearing them
	for i in range(0, path_point_count):
		point_pos.append(_path_2d.curve.get_point_position(i))
		point_in.append(_path_2d.curve.get_point_in(i))
		point_out.append(_path_2d.curve.get_point_out(i))
	
	# Clear the points
	_path_2d.curve.clear_points()
	
	var j = 0
	# Loop from num of points - 1 to 0, with a step of -1
	for i in range(path_point_count - 1, -1, -1):
		# Add the points back in the reverse order
		_path_2d.curve.add_point(point_pos[i], -point_in[i], -point_out[i], j)
		j += 1


func move_trail_followers():
	# Every frame, loop over all of the trail_followers
	# and add trail_speed to their trail_offset
	for follower in trail_followers:
		follower.trail_offset = follower.trail_offset + (-trail_speed if flip_h else trail_speed)
		# If trail_offset is between 0 and 1, it's now "visible"
		# on the path and it's unit_offset should be updated
		if follower.trail_offset >= 0.0 and follower.trail_offset <= 1.0:
			follower.unit_offset = follower.trail_offset
		
		# Cap unit_offset at 1, because trail_offset will be larger than
		# that as items at the end of the trail reach the end of the path
		if follower.trail_offset >= 1.0:
			follower.unit_offset = 1.0
	
	# If the final trail follower has reached the end of the path, remove the wind gust
	var completed_offset = 0.0 if flip_h else 1.0
	var final_follower_index = line_segments - 1 if flip_h else 0
	if trail_followers[final_follower_index].unit_offset == completed_offset:
		remove()


func update_line_gradient():
	for pcnt in range(line_segments + 1):
		gradient.colors[pcnt] = trail_color_gradient.interpolate(gradient.offsets[pcnt])
		gradient.colors[pcnt].a *= \
				trail_color_gradient.interpolate(trail_followers[pcnt].unit_offset).a


func randomize_path():
	randomize()
	var rng = RandomNumberGenerator.new()
	
	for i in range(_path_2d.curve.get_point_count()):
		var curve_point = _path_2d.curve.get_point_position(i)
		curve_point.y += rng.randf_range(-random_y_offset, random_y_offset)
		_path_2d.curve.set_point_position(i, curve_point)


# Clear and redraw the updated line every frame by
# adding each trail follower as a point on the Line2D
func update_line_points():
	clear_points()
	
	for follower in trail_followers:
		add_point(follower.global_position)


func init_trail_followers_and_gradient():
	# For 0 through line_segments (ex. 0 through 20)
	# Add a TrailFollow2D to the Line2D
	# Set it's trail_offset and add it to the array of trail_followers
	for i in range(line_segments + 1):
		var trail_follow_2d = TrailFollow2D.new()
		_path_2d.add_child(trail_follow_2d)
		# Use the inverse of trail_spacing, because it makes more sense that
		# a larger number should give you more spacing, otherwise a value of
		# 0.5 would give you more spacing than a value of 1, for instance.
		var trail_spacing_inverse = 1.0 / trail_spacing
		var trail_length = float(line_segments) * trail_spacing_inverse
		var trail_percentage = float(i) / trail_length
		trail_follow_2d.trail_offset = trail_percentage + (trail_spacing_inverse if flip_h else -trail_spacing_inverse)
		trail_follow_2d.loop = false
		trail_followers.append(trail_follow_2d)
	
	# Set the gradient of the root Line2D node to a new gradient object with
	# line_segments number of color stops, all set to opaque white.
	gradient = Gradient.new()
	gradient.remove_point(0)
	
	for i in range(line_segments):
		gradient.add_point(float(i + 1) / float(line_segments), Color.white)


func remove():
	queue_free()
