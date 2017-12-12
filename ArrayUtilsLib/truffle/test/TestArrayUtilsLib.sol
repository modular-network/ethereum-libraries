pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ArrayUtilsTestContract.sol";
import "../contracts/ArrayUtilsTestContractTwo.sol";

contract TestArrayUtilsLib{
  ArrayUtilsTestContract instance;
  ArrayUtilsTestContractTwo instanceTwo;
  uint[] expectedArray;
  uint[] resultArray;
  bool bResult;
  uint expected;
  uint result;

  function beforeAll(){
    instance = ArrayUtilsTestContract(DeployedAddresses.ArrayUtilsTestContract());
    instanceTwo = ArrayUtilsTestContractTwo(DeployedAddresses.ArrayUtilsTestContractTwo());
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

      result = instance.getSumElements8();

      Assert.equal(result,expected,"The sumElements8 function should add all array elements together and return the sum.");
  }

  function testGetMaxFunction() {
    expected = 1058939;
    result = instance.getGetMaxMiddle256();

    Assert.equal(result,expected,"The getMax256 function should return the max value in an array where the max is in the middle of the array");

    expected = 29588383;
    result = instance.getGetMaxMiddle128();

    Assert.equal(result,expected,"The getMax128 function should return the max value in an array where the max is in the middle of the array");

    expected = 29588;
    result = instance.getGetMaxMiddle64();

    Assert.equal(result,expected,"The getMax64 function should return the max value in an array where the max is in the middle of the array");

    result = instance.getGetMaxMiddle32();

    Assert.equal(result,expected,"The getMax32 function should return the max value in an array where the max is in the middle of the array");

    result = instance.getGetMaxMiddle16();

    Assert.equal(result,expected,"The getMax16 function should return the max value in an array where the max is in the middle of the array");

    expected = 152;
    result = instance.getGetMaxMiddle8();

    Assert.equal(result,expected,"The getMax8 function should return the max value in an array where the max is in the middle of the array");
  }

  function testGetMinFunction() {
    expected = 17;
    result = instance.getGetMinMiddle256();

    Assert.equal(result,expected,"The getMin256 function should return the min value in an array where the min is in the middle of the array");

    expected = 17;
    result = instance.getGetMinMiddle128();

    Assert.equal(result,expected,"The getMin128 function should return the min value in an array where the min is in the middle of the array");

    result = instance.getGetMinMiddle64();

    Assert.equal(result,expected,"The getMin64 function should return the min value in an array where the min is in the middle of the array");

    result = instance.getGetMinMiddle32();

    Assert.equal(result,expected,"The getMin32 function should return the min value in an array where the min is in the middle of the array");

    result = instance.getGetMinMiddle16();

    Assert.equal(result,expected,"The getMin16 function should return the min value in an array where the min is in the middle of the array");

    result = instance.getGetMinMiddle8();

    Assert.equal(result,expected,"The getMin8 function should return the min value in an array where the min is in the middle of the array");
  }

  function testSortedIndexOfFunction(){
    expected = 1;
    (bResult, result) = instanceTwo.getSortedIndexOf256(3);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 1 of the given value");

    expected = 6;
    (bResult, result) = instanceTwo.getSortedIndexOf256(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 5 of the given value");

    expected = 0;
    (bResult, result) = instanceTwo.getSortedIndexOf256(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index 0 of the given value");

    for (uint128 i = 0; i < 4; i++) {
      expected = i;
      (bResult, result) = instanceTwo.getSortedIndexOf128(i);

      Assert.isTrue(bResult,"The indexOf128 function should return true if array contains value");
      Assert.equal(result,expected,"The indexOf128 function should return the index of the given value");
    }

    expected = 4;
    (bResult, result) = instanceTwo.getSortedIndexOf64(4);

    Assert.isTrue(bResult,"The indexOf64 function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf64 function should return the index of the given value");

    expected = 4;
    (bResult, result) = instanceTwo.getSortedIndexOf32(4);

    Assert.isTrue(bResult,"The indexOf32 function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf32 function should return the index of the given value");

    expected = 4;
    (bResult, result) = instanceTwo.getSortedIndexOf16(4);

    Assert.isTrue(bResult,"The indexOf16 function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf16 function should return the index of the given value");

    expected = 4;
    (bResult, result) = instanceTwo.getSortedIndexOf8(4);

    Assert.isTrue(bResult,"The indexOf8 function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf8 function should return the index of the given value");
  }

}
