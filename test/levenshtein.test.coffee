should = require('chai').should()
levenshtein = require('../src/index').levenshtein

describe 'Levenshtein Distance', ->
	update = (charA, charB) -> if charA isnt charB then 1 else 0
	insert = remove = (char) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expectedDistance, expectedMapping) ->
			it stringA + " ↔ " + stringB, ->
				actualAB = levenshtein(stringA, stringB, insert, remove, update)
				actualAB.distance.should.equal(expectedDistance, 'A → B (distance)')
				actualBA = levenshtein(stringB, stringA, insert, remove, update)
				actualBA.distance.should.equal(expectedDistance, 'B → A (distance)')
				actualPairsAB = actualAB.pairs()
				actualPairsBA = actualBA.pairs()
				if expectedMapping?
					expectedPairsAB = expectedMapping
					expectedPairsBA = expectedMapping.map (pair) -> [pair[1], pair[0]]
					actualPairsAB.should.deep.equal expectedPairsAB, 'A → B (pairs)'
					actualPairsBA.should.deep.equal expectedPairsBA, 'B → A (pairs)'

		shouldBeSymmetrical 'a', '', 1, [['a', null]]
		shouldBeSymmetrical 'ab', '', 2, [['b', null], ['a', null]]
		shouldBeSymmetrical 'a', 'a', 0, [['a', 'a']]
		shouldBeSymmetrical 'a', 'b', 1, [['a', 'b']]
		shouldBeSymmetrical 'a', 'ab', 1, [[null, 'b'], ['a', 'a']]
		shouldBeSymmetrical 'b', 'abc', 2, [[null, 'c'], ['b', 'b'], [null, 'a']]
		shouldBeSymmetrical 'ac', 'abc', 1, [['c', 'c'], [null, 'b'], ['a', 'a']]
		shouldBeSymmetrical 'abc', 'adc', 1, [['c', 'c'], ['b', 'd'], ['a', 'a']]

	describeBenchmark = if process.env.BENCHMARK then describe else describe.skip
	describeBenchmark 'should be performant', ->
		@slow(1)
		@timeout(60 * 1000)
		createString = (n, char) -> Array(n + 1).join(char)

		shouldRunFast = (n) ->
			it 'N = ' + n, ->
				stringA = createString n, 'a'
				stringB = createString n, 'b'
				expected = levenshtein(stringA, stringB, insert, remove, update)
				expected.distance.should.equal n

		shouldRunFast 2048
		shouldRunFast 4096
