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

stringifyPairs = (pairs) -> 
	pairs.map (pair) ->
		pair.map (node) ->
			node?.id ? null


describe 'Tree Edit Distance', ->
	children = (node) -> node.children
	update = (nodeA, nodeB) -> if nodeA.id isnt nodeB.id then 1 else 0
	insert = remove = (node) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expected, expectedMapping) ->
			it stringA + " ↔ " + stringB, ->
				treeA = parseTree stringA
				treeB = parseTree stringB
				actualAB = ted(treeA, treeB, children, insert, remove, update)
				actualAB.distance.should.equal(expected, 'A → B')
				actualBA = ted(treeB, treeA, children, insert, remove, update)
				actualBA.distance.should.equal(expected, 'B → A')
				if expectedMapping?
					actualPairsAB = stringifyPairs actualAB.mapping.pairs()
					actualPairsBA = stringifyPairs actualBA.mapping.pairs()
					expectedPairsAB = expectedMapping
					expectedPairsBA = expectedMapping.map (pair) -> [pair[1], pair[0]]
					actualPairsAB.should.deep.equal expectedPairsAB, 'A → B (mapping)'
					actualPairsBA.should.deep.equal expectedPairsBA, 'B → A (mapping)'

		shouldBeSymmetrical "a", "a", 0, [["a", "a"]]
		shouldBeSymmetrical "a", "b", 1, [["a", "b"]]
		shouldBeSymmetrical "(b)a", "b", 1, [["a", null], ["b", "b"]]
		shouldBeSymmetrical "(b,c)a", "b", 2 #TODO: test other mappings.
		shouldBeSymmetrical "(b,c)a", "(c)b", 2
		shouldBeSymmetrical "((c)b,d)a", "(c,(d)a)b", 3
		shouldBeSymmetrical "((c,d)b)a", "(c,d)a", 1
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,e,f)a", 2
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,(e,f)d)b", 1
		shouldBeSymmetrical "((c,(e,f)d)b,x)a", "(c,(e,f)d)b", 2
		shouldBeSymmetrical "(b,(d,e)c)a", "((c)b,d,e)a", 2
		shouldBeSymmetrical "((a,a)a)a", "((a)a)a", 1
		shouldBeSymmetrical "((d,e)b,c)a", "((h,i)g,k)f", 5
		shouldBeSymmetrical "((c,(e,f)d)b)a", "(c,e,f)b", 2
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d)c,e)f", 2
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d)c,x)f", 3
		shouldBeSymmetrical "((a,(b)c)d,e)f", "(((a,b)d,e)c)f", 2

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
