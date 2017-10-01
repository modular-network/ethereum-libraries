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

  function beforeAll() {
    instance = LinkedListTestContract(DeployedAddresses.LinkedListTestContract());
  }

  function testInsert() {

    bResult = instance.exists();
    Assert.isFalse(bResult, "The list is empty so result should be false!");
    result = instance.sizeOf();
    Assert.equal(result,0, "The size of the linked list should be zero!");

    result = instance.getSortedSpot(HEAD,2000,NEXT);
    Assert.equal(result,0, "The list is empty so spot to insert should be 0!");

    instance.insert(0,2000,NEXT);

    bResult = instance.exists();
    Assert.isTrue(bResult, "The list has one element so result should be true!");
    result = instance.sizeOf();
    Assert.equal(result,1, "The size of the linked list should be one!");
  }

  function testSortedInsert() {
    result = instance.getSortedSpot(HEAD,1000,NEXT);
    Assert.equal(result,2000,"Spot to place new value should be 2000!");

    instance.insert(result,1000,PREV);
    result = instance.sizeOf();
    Assert.equal(result,2, "The size of the linked list should be two!");

    (resultPrev,resultNext) = instance.getNode(1000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,2000, "The next node should be 2000!");

    (resultPrev,resultNext) = instance.getNode(2000);
    Assert.equal(resultPrev,1000,"The previous node should be 1000!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");

    result = instance.getSortedSpot(HEAD,3000,NEXT);
    Assert.equal(result,0,"Spot to place new value should be 0!");

    instance.insert(result,3000,PREV);
    result = instance.sizeOf();
    Assert.equal(result,3, "The size of the linked list should be three!");

    (resultPrev,resultNext) = instance.getNode(3000);
    Assert.equal(resultPrev,2000,"The previous node should be 2000!");
    Assert.equal(resultNext,0, "The next node should be HEAD!");
  }

  function testRemove() {
    result = instance.remove(4000);
    Assert.equal(result,0, "should return zero because that node doesnt exist");

    result = instance.remove(2000);
    Assert.equal(result,2000, "2000 should have been deleted");
    result = instance.sizeOf();
    Assert.equal(result,2, "The size of the linked list should be two!");

    (resultPrev,resultNext) = instance.getNode(1000);
    Assert.equal(resultPrev,0,"The previous node should be HEAD!");
    Assert.equal(resultNext,3000, "The next node should be 3000!");
  }

  // function testTimesFunction(){
  //   for(uint256 i = 0; i<5; i++){
  //     f = first[i];
  //     s = second[i];
  //     (bResult,result) = instance.getTimes(f,s);
  //     if(s < 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd){
  //       expected = f * s;
  //       Assert.isFalse(bResult,"The err boolean variable should return false.");
  //       Assert.equal(result,expected,"The times function should multiply the inputs and return the result.");
  //     } else {
  //       Assert.isTrue(bResult,"The err boolean variable should return true if there is overflow.");
  //       Assert.equal(result,0,"The times function should return 0 as the result if there is overflow.");
  //     }
  //   }
  // }

}
