pragma solidity ^0.4.18;

import "./LinkedListLib.sol";

contract LinkedListTestContract {
	using LinkedListLib for LinkedListLib.LinkedList;

	uint256 constant NULL = 0;
  	uint256 constant HEAD = 0;
  	bool constant PREV = false;
  	bool constant NEXT = true;

	LinkedListLib.LinkedList list;

	event LogNotice(string Msg);

	function listExists()
        view public returns (bool)
    {
        return list.listExists();
    }

    /// @dev checks to see if a node exists
    function nodeExists(uint256 _node) view public returns (bool) {
        return list.nodeExists(_node);
    }

    /// @dev Returns the number of elements in the list
    function sizeOf() view public returns (uint256 numElements) {
        return list.sizeOf();
    }

    /// @dev Returns the links of a node as and array
    /// @param _node id of the node to get
    function getNode(uint256 _node)
		view public returns (bool,uint256,uint256)
    {
        return list.getNode(_node);
    }

    /// @dev Returns the link of a node `n` in direction `d`.
    /// @param _node id of the node to step from
    /// @param _direction direction to step in
    function getAdjacent(uint256 _node, bool _direction)
        view public returns (bool,uint256)
    {
        return list.getAdjacent(_node,_direction);
    }

    /// @dev Can be used before `insert` to build an ordered list
    /// @param _node an existing node to search from, e.g. HEAD.
    /// @param _value value to seek
    /// @param _direction direction to seek in
    //  @return next first node beyond '_node' in direction `_direction`
    function getSortedSpot(uint256 _node, uint256 _value, bool _direction)
        view public returns (uint256 next)
    {
        return list.getSortedSpot(_node,_value,_direction);
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
    /// @param _node existing node
    /// @param _new  new node to insert
    /// @param _direction direction to insert node in
    function insert(uint256 _node, uint256 _new, bool _direction) public {
        list.insert(_node,_new,_direction);
    }

    /// @dev removes an entry from the linked list
    /// @param _node node to remove from the list
    function remove(uint256 _node) public returns (uint256) {
        return list.remove(_node);
    }

    /// @dev pushes an enrty to the head of the linked list
    /// @param _node new entry to push to the head
    /// @param _direction push to the head (NEXT) or tail (PREV)
    function push(uint256 _node, bool _direction) public {
        list.push(_node,_direction);
    }

    /// @dev pops the first entry from the linked list
    /// @param _direction pop from the head (NEXT) or the tail (PREV)
    function pop(bool _direction) public returns (uint256) {
        return list.pop(_direction);
    }
}
