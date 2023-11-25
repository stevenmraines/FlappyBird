extends PathFollow2D
class_name TrailFollow2D

# Imagine a Path2D with 4 points (P) like so:
# P--------P--------P--------P
#
# A normal PathFollower2D (F) would start at P1 and traverse to the end to P4 like so:
#     F--------P--------P--------P
# --> P--------F--------P--------P
# --> P--------P--------F--------P
# --> P--------P--------P--------F
#
# But we want a follower that traverses the path with a trail made up of many segments (S):
#     SSSSSSSSSS--------P--------P--------P
# --> P--------SSSSSSSSSS--------P--------P
# --> P--------P--------SSSSSSSSSS--------P
# --> P--------P--------P--------SSSSSSSSSS
#
# Each segment is an instance of this class, and it's trail_offset
# determines its offset from the lead trail follower
var trail_offset := 0.0
