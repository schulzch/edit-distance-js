should = require('chai').should()
distance = require '../src/index'
fs = require 'fs'

#
# Parse a tree in pre-order Newick-style format.
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

describe 'Tree Edit Distance', ->
	children = (node) -> node.children
	update = (nodeA, nodeB) -> if nodeA.id isnt nodeB.id then 1 else 0
	insert = remove = (node) -> 1

	describe 'should be correct', ->
		shouldBeSymmetrical = (stringA, stringB, expected) ->
			it stringA + " ↔ " + stringB, ->
				treeA = parseTree stringA
				treeB = parseTree stringB
				actualAB = distance(treeA, treeB, children, insert, remove, update)
				actualAB.should.equal(expected, 'A → B')
				actualBA = distance(treeB, treeA, children, insert, remove, update)
				actualBA.should.equal(expected, 'B → A')

		shouldBeSymmetrical "a", "a", 0
		shouldBeSymmetrical "a", "b", 1
		shouldBeSymmetrical "(b)a", "b", 1
		shouldBeSymmetrical "(b,c)a", "b", 2
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

	describe 'should be performant', ->
		@timeout(60 * 1000)

		ncbiTree = {}
		before (done) ->
			fs.readFile __dirname + '/data/ncbi-taxonomy.tre', 'utf8', (err, data) ->
				throw err if err?
				ncbiTree = parseTree data
				done()

		it 'NCBI taxonomy', ->
			otherTree = parseTree "a"
			expected = distance(ncbiTree, otherTree, children, insert, remove, update)
			expected.should.equal 311349
