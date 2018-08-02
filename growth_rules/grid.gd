extends Node

func new_vertex(pos):
	var v = {
		"pos": pos,
		"neighbors": []
	}
	return v

func get_suggestion(v, b):
	var pforward = 0.3
	var pturn = 0.5
	var lmin = 20.0
	var lmax = 20.0
	var suggestion = []
	var wait = true

	var prev = v.pos - v.neighbors[v.neighbors.size() - 1].pos
	prev - prev.normalized()
	var n = prev.tangent()
	if n.length() < lmin:
		n = n.normalized() * lmin
	var vp = prev.normalized() * rand_range(lmin, lmax)
	var rnd = randf()
	if rnd <= pforward:
		suggestion.append(new_vertex(v.pos + vp))
		wait = false
	rnd = randf()
	if rnd <= pturn * b * b:
		suggestion.append(new_vertex(v.pos + n))
		wait = true
	rnd = randf()
	if rnd <= pturn * b * b:
		suggestion.append(new_vertex(v.pos - n))
		wait = true
	return suggestion
	