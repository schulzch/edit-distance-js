{Mapping, zero, trackedMin} = require './util'

#
# Computes the Levenshtein distance.
#
# @example
# var stringA = "abcdef";
# var stringB = "abdfgh";
# var insert = remove = function(char) { return 1; };
# var update = function(charA, charB) { return charA !== charB ? 1 : 0; };
# levenshtein(stringA, stringB, insert, remove, update);
#
# @see Levenshtein, Vladimir I. "Binary codes capable of correcting deletions,
# insertions and reversals." Soviet physics doklady. Vol. 10. 1966.
# @see Wagner, Robert A., and Michael J. Fischer. "The string-to-string
# correction problem." Journal of the ACM (JACM) 21.1 (1974): 168-173.
#
levenshtein = (stringA, stringB, insertCb, removeCb, updateCb) ->
	a = stringA
	b = stringB

	track = zero a.length + 1, b.length + 1
	dist = zero a.length + 1, b.length + 1
	for i in [1..a.length] by 1
		dist[i][0] = i
	for j in [1..b.length] by 1
		dist[0][j] = j

	for i in [1..a.length] by 1
		for j in [1..b.length] by 1
			aC = a.charAt(i - 1)
			bC = b.charAt(j - 1)
			min = trackedMin(
				 dist[i - 1][j] + removeCb(aC),
				 dist[i][j - 1] + insertCb(bC),
				 dist[i - 1][j - 1] + updateCb(aC, bC))
			track[i][j] = min.index
			dist[i][j] = min.value

	return {
		distance: dist[a.length][b.length]
		mapping: new Mapping(a, b, track, levenshteinBt)
	}

#
# Backtracks the string-to-string mapping from lower right to upper left.
#
levenshteinBt = (a, b, track) ->
	i = a.length
	j = b.length
	mapping = []
	while i > 0 and j > 0
		switch track[i][j]
			when 0
				# Remove
				mapping.push [a[i - 1], null]
				--i
			when 1
				 # Insert
				mapping.push [null, b[j - 1]]
				--j
			when 2
				# Update
				mapping.push [a[i - 1], b[j - 1]]
				--i
				--j
			else
				throw new Error "Invalid operation #{track[i][j]} at (#{i}, #{j})"
	# Handle epsilon letters.
	if i is 0 and j isnt 0
		while j > 0
			mapping.push [null, b[j - 1]]
			--j
	if i isnt 0 and j is 0
		while i > 0
			mapping.push [a[i - 1], null]
			--i
	return mapping

module.exports = levenshtein
