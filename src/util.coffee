module.exports.fill = (width, height, value) ->
	y = new Array(height)
	y[i] = value for i in [0...height]
	x = new Array(width)
	x[i] = y.slice(0) for i in [0...width]
	return x

module.exports.trackedMin = (a, b, c) ->
	min = {value: a, index: 0 | 0}
	if b < min.value
		min.value = b
		min.index = 1 | 0
	if c < min.value
		min.value = c
		min.index = 2 | 0
	return min
