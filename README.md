# ted.js

`ted.js` computes the [tree edit distance](https://en.wikipedia.org/wiki/Edit_distance) between two given trees.

The Zhang-Shasha algorithm [1] used here has a worst-case complexity of `O(n⁴)`. This can be improved to `O(n³)` using the [APTED](http://tree-edit-distance.dbresearch.uni-salzburg.at/) algorithm [2].

TODO: fix name conflict with configuration manager [ted](https://www.npmjs.com/package/ted).

## Installation

<!--
    $ npm install ted 
-->

## Usage

```javascript
var distance = require('ted');

var children = function(node) { return node.children; };
var insert = remove = function(node) { return 1; };
var update = function(nodeA, nodeB) { return nodeA.id !== nodeB.id ? 1 : 0; };

var rootA = {id: 1, children: [{id: 2}, {id: 3}]};
var rootB = {id: 1, children: [{id: 4}, {id: 3}, {id: 5}]};
console.log(distance(rootA, rootB, children, insert, remove, update));
```

## References

[1] Zhang, Kaizhong, and Dennis Shasha. "Simple fast algorithms for the editing distance between trees and related problems." SIAM journal on computing 18.6 (1989): 1245-1262.

[2] Pawlik, Mateusz, and Nikolaus Augsten. "Tree edit distance: Robust and memory-efficient." Information Systems 56 (2016): 157-173.

## License

Licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0). Copyright &copy; 2016 Christoph Schulz.
