# edit-distance.js [![NPM version](https://badge.fury.io/js/edit-distance.png)](http://badge.fury.io/js/edit-distance) 

`edit-distance.js` computes the [edit distance](https://en.wikipedia.org/wiki/Edit_distance) for strings [1, 2] and trees [3].

## Installation

    $ npm install edit-distance 

## Usage

```javascript
var distance, insert, remove, update, rootA, rootB, children, stringA, stringB;

distance = require('edit-distance');

insert = remove = function(node) { return 1; };

stringA = "abcdef";
stringB = "abdfgh";
update = function(stringA, stringB) { return stringA !== stringB ? 1 : 0; };
console.log(distance.lev(stringA, stringB, insert, remove, update));

rootA = {id: 1, children: [{id: 2}, {id: 3}]};
rootB = {id: 1, children: [{id: 4}, {id: 3}, {id: 5}]};
children = function(node) { return node.children; };
update = function(nodeA, nodeB) { return nodeA.id !== nodeB.id ? 1 : 0; };
console.log(distance.ted(rootA, rootB, children, insert, remove, update));

```

## References

[1] Levenshtein, Vladimir I. "Binary codes capable of correcting deletions, insertions and reversals." Soviet physics doklady. Vol. 10. 1966.

[2] Wagner, Robert A., and Michael J. Fischer. "The string-to-string correction problem." Journal of the ACM (JACM) 21.1 (1974): 168-173.

[3] Zhang, Kaizhong, and Dennis Shasha. "Simple fast algorithms for the editing distance between trees and related problems." SIAM journal on computing 18.6 (1989): 1245-1262.

## License

Licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0). Copyright &copy; 2016 Christoph Schulz.
