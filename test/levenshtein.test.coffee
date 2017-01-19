should = require('chai').should()
levenshtein = require('../src/index').levenshtein

describe 'Levenshtein Distance', ->
	update = (charA, charB) -> if charA isnt charB then 1 else 0
	insert = remove = (char) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expected, expectedMapping) ->
			it stringA + " ↔ " + stringB, ->
				actualAB = levenshtein(stringA, stringB, insert, remove, update)
				actualAB.distance.should.equal(expected, 'A → B')
				actualBA = levenshtein(stringB, stringA, insert, remove, update)
				actualBA.distance.should.equal(expected, 'B → A')
				if expectedMapping?
					actualMapping = actualAB.alignment().mapping
					actualMapping.length.should.equal(expectedMapping.length, 'mapping.length')
					for i in [0...expectedMapping.length]
						expectedPair = expectedMapping[i]
						actualPair = actualMapping[i]
						should.equal(actualPair[0], expectedPair[0], 'mapping[' + i + '][0]')
						should.equal(actualPair[1], expectedPair[1], 'mapping[' + i + '][1]')

		shouldBeSymmetrical 'a', '', 1, [['a', null]]
		shouldBeSymmetrical 'a', 'a', 0, [['a', 'a']]
		shouldBeSymmetrical 'a', 'b', 1, [['a', 'b']]
		shouldBeSymmetrical 'a', 'ab', 1, [[null, 'b'], ['a', 'a']]
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
