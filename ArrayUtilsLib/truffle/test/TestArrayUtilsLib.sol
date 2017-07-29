pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ArrayUtilsTestContract.sol";

contract TestArrayUtilsLib{
  ArrayUtilsTestContract instance;
  uint[] expectedArray;
  uint[] resultArray;
  bool bResult;
  uint expected;
  uint result;

  function beforeAll(){
    instance = ArrayUtilsTestContract(DeployedAddresses.ArrayUtilsTestContract());
  }

  function testSumElementsFunction(){
      expected = 10354;
      result = instance.getSumElements();

      Assert.equal(result,expected,"The sumElements function should add all array elements together and return the sum.");
  }

  function testGetMaxFunction() {
    expected = 1058939;
    result = instance.getGetMaxMiddle();

    Assert.equal(result,expected,"The getMax function should return the max value in an array where the max is in the middle of the array");

    expected = 1058939;
    result = instance.getGetMaxFirst();

    Assert.equal(result,expected,"The getMax function should return the max value in an array where the max is the first element of the array");

    expected = 0xfffff;
    result = instance.getGetMaxLast();

    Assert.equal(result,expected,"The getMax function should return the max value in an array where the max is the first element of the array");
  }

  function testGetMinFunction() {
    expected = 0;
    result = instance.getGetMinMiddle();

    Assert.equal(result,expected,"The getMin function should return the min value in an array where the min is in the middle of the array");
  }

  function testSortedIndexOfFunction(){
    expected = 3;
    (bResult, result) = instance.getSortedIndexOf(7);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 3 of the given value");

    /*expected = 1;
    (bResult, result) = instance.getSortedIndexOf(3);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 1 of the given value");

    /*expected = 5;
    (bResult, result) = instance.getSortedIndexOf(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 5 of the given value");

    expected = 0;
    (bResult, result) = instance.getSortedIndexOf(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 0 of the given value");*/
  }

  function testUnsortedIndexOfFunction() {
    expected = 0;
    (bResult, result) = instance.getUnsortedIndexOf(7);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 3;
    (bResult, result) = instance.getUnsortedIndexOf(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 5;
    (bResult, result) = instance.getUnsortedIndexOf(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");
  }

  function testNoIndexOfFunction() {
    expected = 0;
    (bResult, result) = instance.getNoIndexOf();

    Assert.isFalse(bResult,"The indexOf function should return false if array does not contain value");
    Assert.equal(result,expected,"The indexOf function should return 0 if array does not contain value");
  }

  function testHeapSortFunction(){
    expectedArray.push(0);
    expectedArray.push(1);
    expectedArray.push(1);
    expectedArray.push(3);
    expectedArray.push(4);
    expectedArray.push(4);
    expectedArray.push(7);
    expectedArray.push(9);
    expectedArray.push(1095);
    expectedArray.push(0xff3);
    uint[10] memory r;
    r = instance.getHeapSort();
    resultArray = r;
    Assert.equal(resultArray, expectedArray, "heapSort");
  }
}
