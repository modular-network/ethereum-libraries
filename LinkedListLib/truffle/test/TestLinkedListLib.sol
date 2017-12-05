pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LinkedListTestContract.sol";

contract TestLinkedListLib{
  LinkedListTestContract instance;

  uint256 constant NULL = 0;
  uint256 constant HEAD = 0;
  bool constant PREV = false;
  bool constant NEXT = true;

  uint256 expected;
  bool bResult;
  uint256 result;
  uint256 resultPrev;
  uint256 resultNext;

  event LogNotice(string Msg);

  function beforeAll() public {
    instance = LinkedListTestContract(DeployedAddresses.LinkedListTestContract());
  }

  function testEmptyExists() public {
    bResult = instance.listExists();
    Assert.isFalse(bResult, "The list is empty so result should be false!");
  }

  function testEmptySize() public {
    result = instance.sizeOf();
    Assert.equal(result,0, "The size of the linked list should be zero!");
  }

  function testEmptySortedSpot() public {
    result = instance.getSortedSpot(HEAD,2000,NEXT);
    Assert.equal(result,0, "The list is empty so spot to insert should be 0!");
  }

  function testInsert() public {

    instance.insert(0,2000,NEXT);

    bResult = instance.listExists();
    Assert.isTrue(bResult, "The list has one element so result should be true!");
    result = instance.sizeOf();
    Assert.equal(result,1, "The size of the linked list should be one!");

    bResult = instance.nodeExists(2000);
    Assert.isTrue(bResult, "The node 2000 should exist!");
  }

  function testGetSortedSpot() public {
    result = instance.getSortedSpot(HEAD,1000,NEXT);
    Assert.equal(result,2000,"Spot to place new value should be 2000!");
  }

  function testSortedInsert() public {

    instance.insert(result,1000,PREV);
    result = instance.sizeOf();
    Assert.equal(result,2, "The size of the linked list should be two!");

    (bResult,resultPrev,resultNext) = instance.getNode(1000);
    Assert.isTrue(bResult, "The node should exist!");
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,2000, "The next node should be 2000!");

    (bResult,resultPrev,resultNext) = instance.getNode(1504);
    Assert.isFalse(bResult, "The node shouldnt exist!");
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    (bResult,resultPrev,resultNext) = instance.getNode(2000);
    Assert.equal(resultPrev,1000,"The previous node should be 1000!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    result = instance.getSortedSpot(HEAD,3000,PREV);
    Assert.equal(result,2000,"Spot to place new value should be 2000!");

    instance.insert(result,3000,NEXT);
    result = instance.sizeOf();
    Assert.equal(result,3, "The size of the linked list should be three!");

    (bResult,resultPrev,resultNext) = instance.getNode(3000);
    Assert.equal(resultPrev,2000,"The previous node should be 2000!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    result = instance.getSortedSpot(HEAD,3000,NEXT);
    Assert.equal(result,3000, "Should return the node because it already exists!");

    bResult = instance.nodeExists(3000);
    Assert.isTrue(bResult, "The node 3000 should exist!");

    instance.insert(result,3000,PREV);
    result = instance.sizeOf();
    Assert.equal(result,3, "The size of the linked list should stay three because duplicates cant be added!");

    result = instance.getSortedSpot(HEAD,2500,NEXT);
    Assert.equal(result,3000, "Should return 3000 as the node next to the place for the new node!");

    instance.insert(result,2500,PREV);
    result = instance.sizeOf();
    Assert.equal(result,4, "The size of the linked list should be four!");
  }

  function testGetAdjacent() public {
    (bResult,resultPrev) = instance.getAdjacent(3000,PREV);
    Assert.isTrue(bResult, "The node should exist!");
    Assert.equal(resultPrev, 2500, "The previous adjacent node should be 2500!");

    (bResult,resultNext) = instance.getAdjacent(2000,NEXT);
    Assert.isTrue(bResult, "The node should exist!");
    Assert.equal(resultPrev, 2500, "The next adjacent node should be 2500!");

    (bResult,resultNext) = instance.getAdjacent(1404,NEXT);
    Assert.isFalse(bResult, "The node should not exist!");
    Assert.equal(resultNext,0,"adjacent node should be 0!");

    (bResult,resultPrev) = instance.getAdjacent(1204,PREV);
    Assert.isFalse(bResult, "The node should not exist!");
    Assert.equal(resultPrev,0,"adjacent node should be 0!");

    (bResult,resultNext) = instance.getAdjacent(3000,NEXT);
    Assert.isTrue(bResult, "The node should exist!");
    Assert.equal(resultNext,0,"adjacent node should be 0!");

    (bResult,resultPrev) = instance.getAdjacent(1000,PREV);
    Assert.isTrue(bResult, "The node should exist!");
    Assert.equal(resultPrev,0,"adjacent node should be 0!");
  }

  function testRemove() public {
    result = instance.remove(2500);
    Assert.equal(result,2500, "2500 should have been deleted");
    result = instance.sizeOf();
    Assert.equal(result,3, "The size of the linked list should be 3!");

    result = instance.remove(4000);
    Assert.equal(result,0, "should return zero because that node doesnt exist");

    result = instance.remove(2000);
    Assert.equal(result,2000, "2000 should have been deleted");
    result = instance.sizeOf();
    Assert.equal(result,2, "The size of the linked list should be two!");

    (bResult,resultPrev,resultNext) = instance.getNode(1000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,3000, "The next node should be 3000!");

    result = instance.remove(3000);
    Assert.equal(result,3000, "3000 should have been deleted");
    result = instance.sizeOf();
    Assert.equal(result,1, "The size of the linked list should be one!");

    (bResult,resultPrev,resultNext) = instance.getNode(1000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    result = instance.remove(1000);
    Assert.equal(result,1000, "1000 should have been deleted");
    result = instance.sizeOf();
    Assert.equal(result,0, "The size of the linked list should be zero!");

    (bResult,resultPrev,resultNext) = instance.getNode(0);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");
  }

  function testPushPop() public {
    instance.push(2000,NEXT);
    instance.push(3000,PREV);
    instance.push(1000,NEXT);
    result = instance.sizeOf();
    Assert.equal(result,3, "The size of the linked list should be three!");

    (bResult,resultPrev,resultNext) = instance.getNode(3000);
    Assert.equal(resultPrev,2000,"The previous node should be 2000!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    (bResult,resultPrev,resultNext) = instance.getNode(1000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,2000, "The next node should be 2000!");

    result = instance.pop(NEXT);
    Assert.equal(result,1000, "popped value should be 1000!");
    result = instance.pop(PREV);
    Assert.equal(result,3000, "popped value should be 3000!");

    result = instance.sizeOf();
    Assert.equal(result,1, "The size of the linked list should be one!");

    (bResult,resultPrev,resultNext) = instance.getNode(2000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");
  }

}
