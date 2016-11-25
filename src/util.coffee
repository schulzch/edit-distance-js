module.exports.fill = (width, height, value) ->
	y = new Array(height)
	y[i] = value for i in [0...height]
	x = new Array(width)
	x[i] = y.slice(0) for i in [0...width]
	return x

module.exports.trackedMin = (values...) ->
	min = {value: values[0], index: 0}
	for index in [1...values.length] by 1
		value = values[index]
		if value < min.value
			min.value = value
			min.index = index
	return min
