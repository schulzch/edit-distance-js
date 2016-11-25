{fill, min} = require './util'

postOrderWalk = (root, childrenCb, visitCb) ->
	# Create stacks
	stack1 = []
	stack2 = []
	# Push root to stack1
	stack1.push [undefined, root]
	# Run while stack1 is not empty
	while stack1.length > 0
		# Pop a node from stack1 and push it to stack2
		[index, node] = stack1.pop()
		children = childrenCb(node)
		firstChild = children?[0] ? null
		stack2.push [index, node, firstChild]
		# Push its children to stack1
		for child, index in children ? []
			stack1.push [index, child]
	# Visit all elements of stack2
	while stack2.length > 0
		[index, node, firstChild] = stack2.pop()
		visitCb index, node, firstChild
	return

#
# Computes the tree edit distance (TED).
#
# @example
# var rootA = {id: 1, children: [{id: 2}, {id: 3}]};
# var rootB = {id: 1, children: [{id: 4}, {id: 3}, {id: 5}]};
# var children = function(node) { return node.children; };
# var insert = remove = function(node) { return 1; };
# var update = function(nodeA, nodeB) { return nodeA.id !== nodeB.id ? 1 : 0; };
# distance(rootA, rootB, children, insert, remove, update);
#
# @see Zhang, Kaizhong, and Dennis Shasha. "Simple fast algorithms for the
# editing distance between trees and related problems." SIAM journal on
# computing 18.6 (1989): 1245-1262.
#
# Could be improved using:
# @see Pawlik, Mateusz, and Nikolaus Augsten. "Tree edit distance: Robust and
# memory-efficient." Information Systems 56 (2016): 157-173.
#
distance = (rootA, rootB, childrenCb, insertCb, removeCb, updateCb) ->
	preprocess = (root) ->
		t = {
			# Nodes in post-order.
			nodes: []
			# Leftmost leaf descendant (see paper).
			llds: []
			# Keyroots (see paper).
			keyroots: []
		}

		postOrderWalk root, childrenCb, (index, node, firstChild) ->
			# Push nodes in post-order.
			nIndex = t.nodes.length
			t.nodes.push node

			# Exploit post-order walk to fetch left-most leaf.
			unless firstChild?
				lldIndex = nIndex
			else
				# XXX: replace O(n) lookup with O(1) lookup using node decorator?
				childIndex = t.nodes.indexOf(firstChild)
				lldIndex = t.llds[childIndex]
			t.llds.push lldIndex

			# Exploit property of keyroots.
			if index isnt 0
				t.keyroots.push nIndex
			return

		t.keyroots.sort()

		return t

	treeDistance = (i, j) ->
		aL = tA.llds
		bL = tB.llds
		aN = tA.nodes
		bN = tB.nodes

		iOff = aL[i] - 1
		jOff = bL[j] - 1
		m = i - aL[i] + 2
		n = j - bL[j] + 2

		fdist = fill(m, n, 0)
		for a in [1...m] by 1
			fdist[a][0] = fdist[a - 1][0] + removeCb(aN[a + iOff])
		for b in [1...n] by 1
			fdist[0][b] = fdist[0][b - 1] + insertCb(bN[b + jOff])

		for a in [1...m] by 1
			for b in [1...n] by 1
				if aL[i] is aL[a + iOff] and bL[j] is bL[b + jOff]
					tdist[a + iOff][b + jOff] = fdist[a][b] = min(
						fdist[a - 1][b] + removeCb(aN[a + iOff]),
						fdist[a][b - 1] + insertCb(bN[b + jOff]),
						fdist[a - 1][b - 1] + updateCb(aN[a + iOff], bN[b + jOff]))
				else
					p = aL[a + iOff] - 1 - iOff
					q = bL[b + jOff] - 1 - jOff
					fdist[a][b] = min(
						fdist[a - 1][b] + removeCb(aN[a + iOff]),
						fdist[a][b - 1] + insertCb(bN[b + jOff]),
						fdist[p][q] + tdist[a + iOff][b + jOff])
		return

	tA = preprocess rootA
	tB = preprocess rootB
	tdist = fill(tA.nodes.length, tB.nodes.length, 0)

	for i in tA.keyroots
		for j in tB.keyroots
			treeDistance i, j

	return tdist[tA.nodes.length - 1][tB.nodes.length - 1]

module.exports = distance
