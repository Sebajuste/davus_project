class_name GeometryHelper

###########################	2D	###########################
# Rect2
func get_middle(r:Rect2) -> Vector2:
	return r.position + (r.size * 0.5)

func scale_rectangle(r:Rect2, scale: int, reverseY: bool = false, y_origin:float = 0) -> Rect2:
		if reverseY:
			var pos = reverse_y_axis(r.position * scale, y_origin * scale - r.size.y * scale)
			return Rect2(pos, r.size * scale)
		else:
			return Rect2(r.position * scale, r.size * scale)

# Vector 2
func vector2_ceil(v: Vector2) -> Vector2:
	return Vector2(ceil(v.x), ceil(v.y))

func vector2_floor(v: Vector2) -> Vector2:
	return Vector2(floor(v.x), floor(v.y))

func vector2_round(v: Vector2) -> Vector2:
	return Vector2(round(v.x), round(v.y))

func to_vector2(v: Vector3) -> Vector2:
	return Vector2(v.x, v.y)

func reverse_y_axis(v: Vector2, y_origin:float = 0):
	return Vector2(v.x, y_origin - v.y)

# 2D line-line intersection
func get_line_intersection(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Vector2:
	var denominator = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
	if denominator != 0:
		var t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denominator
		var u = -((p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x)) / denominator
		if (t >= 0 && t < 1 && u >= 0 && u < 1):
			return Vector2(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
	return Vector2.INF

###########################	3D	###########################
# Vector 3
func to_vector3(v: Vector2, z :int = 0) -> Vector3:
	return Vector3(v.x, v.y, z)

func vector3_ceil(v: Vector3) -> Vector3:
	return Vector3(ceil(v.x), ceil(v.y), ceil(v.z))

func vector3_floor(v: Vector3) -> Vector3:
	return Vector3(floor(v.x), floor(v.y), floor(v.z))

func vector3_round(v: Vector3) -> Vector3:
	return Vector3(round(v.x), round(v.y), round(v.z))