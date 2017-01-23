should = require('chai').should()
ted = require('../src/index').ted
fs = require 'fs'

#
# Parse a tree in post-order Newick-style format.
#
parseTree = (string) ->
	ancestors = []
	tree = subtree = {}
	tokens = string.split /\s*(\(|\)|,)\s*/
	for token in tokens
		switch token
			when '('
				subtree = {}
				tree.children = [ subtree ]
				ancestors.push tree
				tree = subtree
			when ','
				subtree = {}
				ancestors[ancestors.length - 1].children.push subtree
				tree = subtree
			when ')'
				tree = ancestors.pop()
			else
				tree.id = token
	return tree

#
# Stringify a set node-node pairs to id-id pairs.
#
stringifyPairs = (pairs) ->
	pairs.map (pair) ->
		pair.map (node) ->
			node?.id ? null

describe 'Tree Edit Distance', ->
	children = (node) -> node.children
	update = (nodeA, nodeB) -> if nodeA.id isnt nodeB.id then 1 else 0
	insert = remove = (node) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expectedDistance, expectedPairs) ->
			it stringA + " ↔ " + stringB, ->
				treeA = parseTree stringA
				treeB = parseTree stringB
				actualAB = ted(treeA, treeB, children, insert, remove, update)
				actualAB.distance.should.equal(expectedDistance, 'A → B (distance)')
				actualBA = ted(treeB, treeA, children, insert, remove, update)
				actualBA.distance.should.equal(expectedDistance, 'B → A (distance)')
				actualPairsAB = stringifyPairs actualAB.pairs()
				actualPairsBA = stringifyPairs actualBA.pairs()
				if expectedPairs?
					expectedPairsAB = expectedPairs
					expectedPairsBA = expectedPairs.map (pair) -> [pair[1], pair[0]]
					actualPairsAB.should.deep.equal expectedPairsAB, 'A → B (pairs)'
					actualPairsBA.should.deep.equal expectedPairsBA, 'B → A (pairs)'

		shouldBeSymmetrical "a", "a", 0, [["a", "a"]]
		shouldBeSymmetrical "a", "b", 1, [["a", "b"]]
		shouldBeSymmetrical "(b)a", "b", 1, [["a", null], ["b", "b"]]
		shouldBeSymmetrical "(b,c)a", "a", 2, [["a", "a"], ["c", null], ["b", null]]
		shouldBeSymmetrical "(c,b)a", "b", 2, [["a", null], ["b", "b"], ["c", null]]
		shouldBeSymmetrical "(b,c)a", "b", 2, [["a", null], ["c", "b"], ["b", null]]
		shouldBeSymmetrical "(b,c)a", "(c)b", 2, [["a", "b"], ["c", "c"], ["b", null]]
		shouldBeSymmetrical "((c)b,d)a", "(c,(d)a)b", 3, [["a", "b"], [null, "a"], ["d", "d"], ["b", null], ["c", "c"]]
		shouldBeSymmetrical "((c,d)b)a", "(c,d)a", 1, [["a", "a"], ["b", null], ["d", "d"], ["c", "c"]]
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,e,f)a", 2, [["a", "a"], ["b", null], ["d", null], ["f", "f"], ["e", "e"], ["c", "c"]]
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,(e,f)d)b", 1, [["a", null], ["b", "b"], ["d", "d"], ["f", "f"], ["e", "e"], ["c", "c"]]
		shouldBeSymmetrical "((c,(e,f)d)b,x)a", "(c,(e,f)d)b", 2, [["a", null], [null, "b"], [null, "d"], ["x", "f"], ["b", null], ["d", null], ["f", "e"], ["e", "c"], ["c", null]]
		shouldBeSymmetrical "(b,(d,e)c)a", "((c)b,d,e)a", 2, [["a", "a"], ["c", null], ["e", "e"], ["d", "d"], ["b", "b"], [null, "c"]]
		shouldBeSymmetrical "((a,a)a)a", "((a)a)a", 1, [["a", "a"], ["a", "a"], ["a", "a"], ["a", null]]
		shouldBeSymmetrical "((d,e)b,c)a", "((h,i)g,k)f", 5, [["a", "f"], ["c", "k"], ["b", "g"], ["e", "i"], ["d", "h"]]
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,e,f)b", 2, [["a", null], ["b", "b"], ["d", null], ["f", "f"], ["e", "e"], ["c", "c"]]
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d)c,e)f", 2, [["f", "f"], ["e", "e"], [null, "c"], ["d", "d"], ["c", null], ["b", "b"], ["a", "a"]]
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d)c,x)f", 3, [["f", "f"], ["e", "x"], [null, "c"], ["d", "d"], ["c", null], ["b", "b"], ["a", "a"]]
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d,e)c)f", 2, [["f", "f"], [null, "c"], ["e", "e"], ["d", "d"], ["c", null], ["b", "b"], ["a", "a"]]

	describeBenchmark = if process.env.BENCHMARK then describe else describe.skip
	describeBenchmark 'should be performant', ->
		@slow(1)
		@timeout(60 * 1000)

		ncbiTree = {}
		before (done) ->
			fs.readFile __dirname + '/data/ncbi-taxonomy.tre', 'utf8', (err, data) ->
				throw err if err?
				ncbiTree = parseTree data
				done()

		it 'NCBI taxonomy', ->
			otherTree = parseTree "a"
			expected = ted(ncbiTree, otherTree, children, insert, remove, update)
			expected.distance.should.equal 311349
