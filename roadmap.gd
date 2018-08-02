extends ColorRect

var vertices = []
func new_vertex(x, y):
	return {
			"pos": Vector2(x, y),
			"neighbors": [],
			"type": 0
	}

# Initial points added "axiom". I'm too lazy to properly set these up

var min_distance = 3.0
var pgrow = 0.2

var axiom = [
	new_vertex(0.0, 0.0),
	new_vertex(-10.0, 0.0),
	new_vertex(-20.0, 0.0),
	new_vertex(-30.0, 10.0),
]
# Got this routine from forum:
# https://godotengine.org/qa/24522/detect-if-a-2d-line-is-inside-another-2d-line
func are_lines_intersecting(a, b, c, d):
	var cd = d - c
	var ab = b - a
	var div = cd.y * ab.x - cd.x * ab.y
	if abs(div) > 0.001:
		var ac = a - c
		var ua = ((cd.x * ac.y) - (cd.y * ac.x)) / div
		if not ua >= 0.0 or not ua <= 1.0:
			return false
		var ub = ((ab.x * ac.y) - (ab.y * ac.x)) / div
		if ub >= 0.0 and ub <= 1.0:
			return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	for k in axiom:
		for l in axiom:
			if k == l:
				continue
			k.neighbors.append(l)
		vertices.append(k)
var minpos = Vector2()
var maxpos = Vector2()
var vertex_queue = []

func check_suggestion(s, n, front):
	var newfront = front.duplicate()
	if abs(s.pos.x) > 240 || abs(s.pos.y) > 240:
		return newfront
	if s.pos.distance_to(n.pos) < min_distance:
		return newfront
	for k in n.neighbors:
		if s.pos.distance_to(k.pos) < min_distance:
			return newfront

# requires partitioning algorithm for speedup
	for k in vertices:
		if s.pos.distance_to(k.pos) < min_distance:
			if ! k in n.neighbors:
				n.neighbors.append(k)
			if ! n in k.neighbors:
				k.neighbors.append(n)
			return newfront
		for kn in k.neighbors:
			if n.pos == k.pos || n == k || n == kn || n.pos == kn.pos:
				continue
			if are_lines_intersecting(s.pos, n.pos, k.pos, kn.pos):
				return newfront
	if ! s in n.neighbors:
		n.neighbors.append(s)
	if ! n in s.neighbors:
		s.neighbors.append(n)
	vertices.append(s)
	newfront.append(s)
	return newfront

# simple density map
# better use image as data source
func get_density(pos):
	if pos.length() > 280:
		return 0.0
	else:
		return 0.7

func get_suggestion(v):
	if randf() <= pgrow:
		return $grid.get_suggestion(v, get_density(v.pos))
	return []

func iteration(front):
	var newfront = []
#	var s = calc_s(front[0])
	for k in front:
		var suggestion = get_suggestion(k)
#		print(s)
		for l in suggestion:
			newfront = check_suggestion(l, k, newfront)
# better use priority queue for actual code
	if vertex_queue.size() > 0:
		newfront.append(vertex_queue.pop_front())
	return newfront

func step():
	var front = []
	front += vertices
	while front.size() > 0 || vertex_queue.size() > 0:
		front = iteration(front)
var vertexcount = 0
func _process(delta):
	for k in vertices:
		if minpos.x > k.pos.x:
			minpos.x = k.pos.x
		if minpos.y > k.pos.y:
			minpos.y = k.pos.y
		if maxpos.x < k.pos.x:
			maxpos.x = k.pos.x
		if maxpos.y < k.pos.y:
			maxpos.y = k.pos.y
	step()
	if vertexcount != vertices.size():
		vertexcount = vertices.size()
		print("num: ", vertexcount)
	update()
		

func _draw():
	var sz = maxpos - minpos
	if sz.length() == 0.0:
		return
#	print("boo: ", sz)
	var mulx = rect_size.x / abs(sz.x)
	var muly = rect_size.y / abs(sz.y)
	var posmul = Vector2(mulx, muly)
#	print("mulx: ", mulx, " muly: ", muly)
	for k in vertices:
		for l in k.neighbors:
			var from = Vector2(k.pos.x * mulx, k.pos.y * muly) - Vector2(minpos.x * mulx, minpos.y * muly)
			var to = Vector2(l.pos.x * mulx, l.pos.y * muly) - Vector2(minpos.x * mulx, minpos.y * muly)
#			print("line: ", from, " ", to)
			draw_line(from, to, Color(0, 1, 0))
			draw_circle(from, 3, Color(0, 1, 1))
