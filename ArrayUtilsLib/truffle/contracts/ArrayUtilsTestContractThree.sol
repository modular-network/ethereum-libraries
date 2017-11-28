pragma solidity ^0.4.18;

import "./Array256Lib.sol";
import "./Array128Lib.sol";
import "./Array64Lib.sol";
import "./Array32Lib.sol";
import "./Array16Lib.sol";
import "./Array8Lib.sol";

contract ArrayUtilsTestContractThree {
  using Array256Lib for uint256[];
  using Array128Lib for uint128[];
  using Array64Lib for uint64[];
  using Array32Lib for uint32[];
  using Array16Lib for uint16[];
  using Array8Lib for uint8[];

  uint256[] array256;
  uint128[] array128;
  uint64[] array64;
  uint32[] array32;
  uint16[] array16;
  uint8[] array8;

  event Print(string message, bytes32 test);

  function getHeapSort256() returns (uint256[10] memory r){
    delete array256;
    array256.push(3);
    array256.push(1);
    array256.push(9);
    array256.push(7);
    array256.push(4);
    array256.push(4);
    array256.push(0xff3);
    array256.push(0);
    array256.push(1095);
    array256.push(1);
    array256.heapSort();
    for(uint256 i = 0; i<array256.length; i++){
      r[i] = array256[i];
    }
  }

  function getHeapSort128() returns (uint128[10] memory r){
    delete array128;
    array128.push(3);
    array128.push(1);
    array128.push(9);
    array128.push(7);
    array128.push(4);
    array128.push(4);
    array128.push(0xff3);
    array128.push(0);
    array128.push(1095);
    array128.push(1);
    array128.heapSort();
    for(uint256 i = 0; i<array128.length; i++){
      r[i] = array128[i];
    }
  }

  function getHeapSort64() returns (uint64[10] memory r){
    delete array64;
    array64.push(3);
    array64.push(1);
    array64.push(9);
    array64.push(7);
    array64.push(4);
    array64.push(4);
    array64.push(0xff3);
    array64.push(0);
    array64.push(1095);
    array64.push(1);
    array64.heapSort();
    for(uint256 i = 0; i<array64.length; i++){
      r[i] = array64[i];
    }
  }

  function getHeapSort32() returns (uint32[10] memory r){
    delete array32;
    array32.push(3);
    array32.push(1);
    array32.push(9);
    array32.push(7);
    array32.push(4);
    array32.push(4);
    array32.push(0xff3);
    array32.push(0);
    array32.push(1095);
    array32.push(1);
    array32.heapSort();
    for(uint256 i = 0; i<array32.length; i++){
      r[i] = array32[i];
    }
  }

  function getHeapSort16() returns (uint16[10] memory r){
    delete array16;
    array16.push(3);
    array16.push(1);
    array16.push(9);
    array16.push(7);
    array16.push(4);
    array16.push(4);
    array16.push(0xff3);
    array16.push(0);
    array16.push(1095);
    array16.push(1);
    array16.heapSort();
    for(uint256 i = 0; i<array16.length; i++){
      r[i] = array16[i];
    }
  }

  function getHeapSort8() returns (uint8[10] memory r){
    delete array8;
    array8.push(3);
    array8.push(1);
    array8.push(9);
    array8.push(7);
    array8.push(4);
    array8.push(4);
    array8.push(0xfe);
    array8.push(0);
    array8.push(109);
    array8.push(1);
    array8.heapSort();
    for(uint256 i = 0; i<array8.length; i++){
      r[i] = array8[i];
    }
  }

  function getUniq8() returns (uint8[5] memory r) {
    uint arrayNewLength;

    delete array8;

    array8.push(1);
    array8.push(1);
    array8.push(2);
    array8.push(7);
    array8.push(4);
    array8.push(4);
    array8.push(0);
    array8.push(1);

    arrayNewLength = array8.uniq();

    for (uint8 i = 0; i < arrayNewLength; i++) {
      r[i] = array8[i];
    }
  }

  function getUniq16() returns (uint16[7] memory r) {
    uint arrayNewLength;

    delete array16;

    array16.push(1);
    array16.push(1);
    array16.push(2);
    array16.push(7);
    array16.push(4);
    array16.push(4);
    array16.push(0);
    array16.push(0xff3);
    array16.push(1095);
    array16.push(1);

    arrayNewLength = array16.uniq();

    for (uint16 i = 0; i < arrayNewLength; i++) {
      r[i] = array16[i];
    }
  }

  function getUniq32() returns (uint32[7] memory r) {
    uint arrayNewLength;

    delete array32;

    array32.push(1);
    array32.push(1);
    array32.push(2);
    array32.push(7);
    array32.push(4);
    array32.push(4);
    array32.push(0);
    array32.push(0xff3);
    array32.push(1095);
    array32.push(1);

    arrayNewLength = array32.uniq();

    for (uint32 i = 0; i < arrayNewLength; i++) {
      r[i] = array32[i];
    }
  }

  function getUniq64() returns (uint64[7] memory r) {
    uint arrayNewLength;

    delete array64;

    array64.push(1);
    array64.push(1);
    array64.push(2);
    array64.push(7);
    array64.push(4);
    array64.push(4);
    array64.push(0);
    array64.push(0xff3);
    array64.push(1095);
    array64.push(1);

    arrayNewLength = array64.uniq();

    for (uint64 i = 0; i < arrayNewLength; i++) {
      r[i] = array64[i];
    }
  }

  function getUniq128() returns (uint128[7] memory r) {
    uint arrayNewLength;

    delete array128;

    array128.push(1);
    array128.push(1);
    array128.push(2);
    array128.push(7);
    array128.push(4);
    array128.push(4);
    array128.push(0);
    array128.push(0xff3);
    array128.push(1095);
    array128.push(1);

    arrayNewLength = array128.uniq();

    for (uint128 i = 0; i < arrayNewLength; i++) {
      r[i] = array128[i];
    }
  }

  function getUniq256() returns (uint256[7] memory r) {
    uint arrayNewLength;

    delete array256;

    array256.push(1);
    array256.push(1);
    array256.push(2);
    array256.push(7);
    array256.push(4);
    array256.push(4);
    array256.push(0);
    array256.push(0xff3);
    array256.push(1095);
    array256.push(1);

    arrayNewLength = array256.uniq();

    for (uint256 i = 0; i < arrayNewLength; i++) {
      r[i] = array256[i];
    }
  }

}
