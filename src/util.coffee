#
# Element-to-element mapping container.
#
# This class deferes the backtracking process to compute the mapping and may
# compute the aligment.
#
module.exports.Mapping = class Mapping
	constructor: (@a, @b, @distance, @track, @backtrackFn) ->
		@pairCache = null

	#
	# Returns the actual pairs of the mapping.
	#
	pairs: =>
		unless @pairCache?
			@pairCache = @backtrackFn @a, @b, @track
		return @pairCache

	#
	# Returns the alignment
	#
	alignment: =>
		pairs = @pairs()
		alignmentA = [] # B to A
		alignmentB = [] # A to B
		for pair in pairs.reverse()
			alignmentA.push pair[0]
			alignmentB.push pair[1]
		return {
			alignmentA: alignmentA
			alignmentB: alignmentB
		}

#
# Returns a zero-filled 2D array.
#
module.exports.zero = (width, height) ->
	x = new Array(width)
	for i in [0...width] by 1
		y = x[i] = new Array(height)
		for j in [0...height] by 1
			y[j] = 0
	return x

#
# Computes the minimum of (a, b, c) while
#
module.exports.trackedMin = (a, b, c) ->
	min = {value: a, index: 0 | 0}
	if b < min.value
		min.value = b
		min.index = 1 | 0
	if c < min.value
		min.value = c
		min.index = 2 | 0
	return min
