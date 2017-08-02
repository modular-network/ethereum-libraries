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
      result = instance.getSumElements256();

      Assert.equal(result,expected,"The sumElements function should add all array elements together and return the sum.");

      expected = 15;
      result = instance.getSumElements128();

      Assert.equal(result,expected,"The sumElements128 function should add all array elements together and return the sum.");

      result = instance.getSumElements64();

      Assert.equal(result,expected,"The sumElements64 function should add all array elements together and return the sum.");

      result = instance.getSumElements32();

      Assert.equal(result,expected,"The sumElements32 function should add all array elements together and return the sum.");

      result = instance.getSumElements16();

      Assert.equal(result,expected,"The sumElements16 function should add all array elements together and return the sum.");

      //result = instance.getSumElements8();

      //Assert.equal(result,expected,"The sumElements8 function should add all array elements together and return the sum.");
  }

  function testGetMaxFunction() {
    expected = 1058939;
    result = instance.getGetMaxMiddle256();

    Assert.equal(result,expected,"The getMax256 function should return the max value in an array where the max is in the middle of the array");

    expected = 29588383;
    result = instance.getGetMaxMiddle128();

    Assert.equal(result,expected,"The getMax128 function should return the max value in an array where the max is in the middle of the array");
  }

  function testGetMinFunction() {
    expected = 17;
    result = instance.getGetMinMiddle256();

    Assert.equal(result,expected,"The getMin256 function should return the min value in an array where the min is in the middle of the array");

    expected = 17;
    result = instance.getGetMinMiddle128();

    Assert.equal(result,expected,"The getMin128 function should return the min value in an array where the min is in the middle of the array");
  }

  function testSortedIndexOfFunction(){
    expected = 3;
    (bResult, result) = instance.getSortedIndexOf256(7);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 3 of the given value");

    expected = 1;
    (bResult, result) = instance.getSortedIndexOf256(3);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 1 of the given value");

    expected = 6;
    (bResult, result) = instance.getSortedIndexOf256(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 5 of the given value");

    expected = 0;
    (bResult, result) = instance.getSortedIndexOf256(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 0 of the given value");
  }

  function testUnsortedIndexOfFunction() {
    expected = 0;
    (bResult, result) = instance.getUnsortedIndexOf256(7);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 3;
    (bResult, result) = instance.getUnsortedIndexOf256(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 5;
    (bResult, result) = instance.getUnsortedIndexOf256(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");
  }

  function testNoIndexOfFunction() {
    expected = 0;
    (bResult, result) = instance.getNoIndexOf256(10,true);

    Assert.isFalse(bResult,"The indexOf function should return false if array does not contain value");
    Assert.equal(result,expected,"The indexOf function should return 0 if array does not contain value");

    expected = 0;
    (bResult, result) = instance.getNoIndexOf256(39482,false);

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
