module.exports.zero = (width, height) ->
	x = new Array(width)
	for i in [0...width] by 1
		y = x[i] = new Array(height)
		for j in [0...height] by 1
			y[j] = 0
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
