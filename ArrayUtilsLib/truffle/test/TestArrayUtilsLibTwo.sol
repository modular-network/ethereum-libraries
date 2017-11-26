pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ArrayUtilsTestContractTwo.sol";
import "../contracts/ArrayUtilsTestContractThree.sol";

contract TestArrayUtilsLibTwo{
  ArrayUtilsTestContractTwo instanceTwo;
  ArrayUtilsTestContractThree instanceThree;
  uint[] expectedArray;
  uint[] resultArray;
  bool bResult;
  uint expected;
  uint result;

  function beforeAll(){
    instanceTwo = ArrayUtilsTestContractTwo(DeployedAddresses.ArrayUtilsTestContractTwo());
    instanceThree = ArrayUtilsTestContractThree(DeployedAddresses.ArrayUtilsTestContractThree());
  }

  function testUnsortedIndexOfFunction() {
    expected = 0;
    (bResult, result) = instanceTwo.getUnsortedIndexOf256(7);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 3;
    (bResult, result) = instanceTwo.getUnsortedIndexOf256(1);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    expected = 5;
    (bResult, result) = instanceTwo.getUnsortedIndexOf256(1095);

    Assert.isTrue(bResult,"The indexOf function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf function should return the index of the given value");

    (bResult, result) = instanceTwo.getUnsortedIndexOf64(1095);

    Assert.isTrue(bResult,"The indexOf64 function should return true if array contains value");
    Assert.equal(result,expected,"The indexOf64 function should return the index of the given value");
  }

  function testNoIndexOfFunction() {
    expected = 0;
    (bResult, result) = instanceTwo.getNoIndexOf256(10,true);

    Assert.isFalse(bResult,"The indexOf function should return false if array does not contain value");
    Assert.equal(result,expected,"The indexOf function should return 0 if array does not contain value");

    expected = 0;
    (bResult, result) = instanceTwo.getNoIndexOf256(39482,false);

    Assert.isFalse(bResult,"The indexOf function should return false if array does not contain value");
    Assert.equal(result,expected,"The indexOf function should return 0 if array does not contain value");

    (bResult, result) = instanceTwo.getNoIndexOf64(39482,false);

    Assert.isFalse(bResult,"The indexOf64 function should return false if array does not contain value");
    Assert.equal(result,expected,"The indexOf64 function should return 0 if array does not contain value");
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

    uint[10] memory r1;
    r1 = instanceThree.getHeapSort256();
    resultArray = r1;
    Assert.equal(resultArray, expectedArray, "heapSort");

    uint128[10] memory r2;
    r2 = instanceThree.getHeapSort128();
    resultArray = r2;
    Assert.equal(resultArray, expectedArray, "heapSort");

    uint64[10] memory r3;
    r3 = instanceThree.getHeapSort64();
    resultArray = r3;
    Assert.equal(resultArray, expectedArray, "heapSort");

    uint32[10] memory r4;
    r4 = instanceThree.getHeapSort32();
    resultArray = r4;
    Assert.equal(resultArray, expectedArray, "heapSort");

    uint16[10] memory r5;
    r5 = instanceThree.getHeapSort16();
    resultArray = r5;
    Assert.equal(resultArray, expectedArray, "heapSort");

    delete expectedArray;

    expectedArray.push(0);
    expectedArray.push(1);
    expectedArray.push(1);
    expectedArray.push(3);
    expectedArray.push(4);
    expectedArray.push(4);
    expectedArray.push(7);
    expectedArray.push(9);
    expectedArray.push(109);
    expectedArray.push(0xfe);

    uint8[10] memory r6;
    r6 = instanceThree.getHeapSort8();
    resultArray = r6;
    Assert.equal(resultArray, expectedArray, "heapSort");
  }

  function testUniqFunction(){
    delete expectedArray;

    expectedArray.push(1);
    expectedArray.push(2);
    expectedArray.push(7);
    expectedArray.push(4);
    expectedArray.push(0);

    resultArray = instanceThree.getUniq8();
    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 8-bit array");

    expectedArray.push(0xff3);
    expectedArray.push(1095);

    resultArray = instanceThree.getUniq16();
    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 16-bit array");

    resultArray = instanceThree.getUniq32();

    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 32-bit array");

    resultArray = instanceThree.getUniq64();
    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 64-bit array");

    resultArray = instanceThree.getUniq128();
    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 128-bit array");

    resultArray = instanceThree.getUniq256();
    Assert.equal(resultArray, expectedArray, "The uniq function did not returned the expected values for a 256-bit array");
  }

}
