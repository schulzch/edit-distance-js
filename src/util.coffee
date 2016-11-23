module.exports.fill = (width, height, value) ->
	y = new Array(height)
	y[i] = value for i in [0...height]
	x = new Array(width)
	x[i] = y.slice(0) for i in [0...width]
	return x

module.exports.min = (a, b, c) ->
	Math.min(Math.min(a, b), c)
