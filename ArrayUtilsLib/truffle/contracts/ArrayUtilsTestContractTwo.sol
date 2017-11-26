pragma solidity ^0.4.18;

import "./Array256Lib.sol";
import "./Array128Lib.sol";
import "./Array64Lib.sol";
import "./Array32Lib.sol";
import "./Array16Lib.sol";
import "./Array8Lib.sol";

contract ArrayUtilsTestContractTwo {
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

  function getSortedIndexOf256(uint256 value) returns (bool,uint256){
    delete array256;
    array256.push(1);
    array256.push(3);
    array256.push(4);
    array256.push(7);
    array256.push(8);
    array256.push(9);
    array256.push(1095);
    return array256.indexOf(value,true);
  }

  function getSortedIndexOf128(uint128 value) returns (bool,uint256) {
    delete array128;
    array128.push(0);
    array128.push(1);
    array128.push(2);
    array128.push(3);
    array128.push(4);
    array128.push(5);
    array128.push(6);
    array128.push(7);
    array128.push(8);
    array128.push(9);
    array128.push(1095);
    return array128.indexOf(value,true);
  }

  function getSortedIndexOf64(uint64 value) returns (bool,uint256) {
    delete array64;
    array64.push(0);
    array64.push(1);
    array64.push(2);
    array64.push(3);
    array64.push(4);
    array64.push(5);
    array64.push(6);
    array64.push(7);
    array64.push(8);
    array64.push(9);
    array64.push(1095);
    return array64.indexOf(value,true);
  }

  function getSortedIndexOf32(uint32 value) returns (bool,uint256) {
    delete array32;
    array32.push(0);
    array32.push(1);
    array32.push(2);
    array32.push(3);
    array32.push(4);
    array32.push(5);
    array32.push(6);
    array32.push(7);
    array32.push(8);
    array32.push(9);
    array32.push(1095);
    return array32.indexOf(value,true);
  }

  function getSortedIndexOf16(uint16 value) returns (bool,uint256) {
    delete array16;
    array16.push(0);
    array16.push(1);
    array16.push(2);
    array16.push(3);
    array16.push(4);
    array16.push(5);
    array16.push(6);
    array16.push(7);
    array16.push(8);
    array16.push(9);
    array16.push(109);
    return array16.indexOf(value,true);
  }

  function getSortedIndexOf8(uint8 value) returns (bool,uint256) {
    delete array8;
    array8.push(0);
    array8.push(1);
    array8.push(2);
    array8.push(3);
    array8.push(4);
    array8.push(5);
    array8.push(6);
    array8.push(7);
    array8.push(8);
    array8.push(9);
    array8.push(109);
    return array8.indexOf(value,true);
  }

  function getUnsortedIndexOf256(uint256 value) returns (bool,uint256) {
    delete array256;
    array256.push(7);
    array256.push(0xffff);
    array256.push(3);
    array256.push(1);
    array256.push(9);
    array256.push(1095);
    return array256.indexOf(value,false);
  }

  function getUnsortedIndexOf64(uint64 value) returns (bool,uint256) {
    delete array64;
    array64.push(7);
    array64.push(0xffff);
    array64.push(3);
    array64.push(1);
    array64.push(9);
    array64.push(1095);
    return array64.indexOf(value,false);
  }

  function getNoIndexOf256(uint256 value, bool isSorted) returns (bool,uint256) {
    delete array256;
    array256.push(1);
    array256.push(3);
    array256.push(4);
    array256.push(7);
    array256.push(9);
    array256.push(1095);
    return array256.indexOf(value,isSorted);
  }

  function getNoIndexOf64(uint64 value, bool isSorted) returns (bool,uint256) {
    delete array64;
    array64.push(1);
    array64.push(3);
    array64.push(4);
    array64.push(7);
    array64.push(9);
    array64.push(1095);
    return array64.indexOf(value,isSorted);
  }

}
