should = require('chai').should()
distance = require('../src/index').lev

describe 'Levenshtein Distance', ->
	update = (charA, charB) -> if charA isnt charB then 1 else 0
	insert = remove = (char) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expected) ->
			it stringA + " ↔ " + stringB, ->
				actualAB = distance(stringA, stringB, insert, remove, update)
				actualAB.should.equal(expected, 'A → B')
				actualBA = distance(stringB, stringA, insert, remove, update)
				actualBA.should.equal(expected, 'B → A')

		shouldBeSymmetrical 'a', '', 1
		shouldBeSymmetrical 'a', 'a', 0
		shouldBeSymmetrical 'a', 'b', 1
		shouldBeSymmetrical 'a', 'ab', 1
		shouldBeSymmetrical 'ac', 'abc', 1
		shouldBeSymmetrical 'abc', 'adc', 1

	describe 'should be performant', ->
		@slow(1)
		@timeout(60 * 1000)
		createString = (n, char) -> Array(n + 1).join(char)

		shouldRunFast = (n) ->
			it 'N = ' + n, ->
				stringA = createString n, 'a'
				stringB = createString n, 'b'
				expected = distance(stringA, stringB, insert, remove, update)
				expected.should.equal n

		shouldRunFast 2048
		shouldRunFast 4096
