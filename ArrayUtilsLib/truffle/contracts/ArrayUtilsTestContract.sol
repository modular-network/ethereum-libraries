pragma solidity ^0.4.18;

import "./Array256Lib.sol";
import "./Array128Lib.sol";
import "./Array64Lib.sol";
import "./Array32Lib.sol";
import "./Array16Lib.sol";
import "./Array8Lib.sol";

contract ArrayUtilsTestContract {
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

  function getSumElements256() returns (uint256){
    delete array256;
    array256.push(2);
    array256.push(10);
    array256.push(0);
    array256.push(10342);
    return array256.sumElements();
  }

  function getGetMaxMiddle256() returns (uint256){
    delete array256;
    array256.push(2);
    array256.push(0);
    array256.push(1058939);
    array256.push(0xfffff);
    return array256.getMax();
  }

  function getGetMinMiddle256() returns (uint256){
    delete array256;
    array256.push(1058939);
    array256.push(17);
    array256.push(21);
    array256.push(0xfffff);
    return array256.getMin();
  }

  function getSumElements128() returns (uint256 test){
    delete array128;
    array128.push(2);
    array128.push(4);
    array128.push(6);
    array128.push(3);

    return array128.sumElements();
  }

  function getSumElements64() returns (uint256 test){
    delete array64;
    array64.push(2);
    array64.push(4);
    array64.push(6);
    array64.push(3);

    return array64.sumElements();
  }

  function getSumElements32() returns (uint256 test){
    delete array32;
    array32.push(2);
    array32.push(4);
    array32.push(6);
    array32.push(3);

    return array32.sumElements();
  }

  function getSumElements16() returns (uint256 test){
    delete array16;
    array16.push(2);
    array16.push(4);
    array16.push(6);
    array16.push(3);

    return array16.sumElements();
  }

  function getSumElements8() returns (uint256 test){
    delete array8;
    array8.push(2);
    array8.push(4);
    array8.push(6);
    array8.push(3);

    return array8.sumElements();
  }

  function getGetMaxMiddle128() returns (uint128){
    delete array128;
    array128.push(2);
    array128.push(29588383);
    array128.push(0);
    array128.push(0xfffff);


    return array128.getMax();
  }

  function getGetMaxMiddle64() returns (uint64){
    delete array64;
    array64.push(2);
    array64.push(29588);
    array64.push(0);
    array64.push(0xff);


    return array64.getMax();
  }

  function getGetMaxMiddle32() returns (uint32){
    delete array32;
    array32.push(2);
    array32.push(29588);
    array32.push(0);
    array32.push(0xff);


    return array32.getMax();
  }

  function getGetMaxMiddle16() returns (uint16){
    delete array16;
    array16.push(2);
    array16.push(29588);
    array16.push(0);
    array16.push(0xff);


    return array16.getMax();
  }

  function getGetMaxMiddle8() returns (uint8){
    delete array8;
    array8.push(2);
    array8.push(29);
    array8.push(152);
    array8.push(0xf);


    return array8.getMax();
  }

  function getGetMinMiddle128() returns (uint128){
    delete array128;
    array128.push(1058939);
    array128.push(73);
    array128.push(17);
    array128.push(0xfffff);
    return array128.getMin();
  }

  function getGetMinMiddle64() returns (uint64){
    delete array64;
    array64.push(1058939);
    array64.push(73);
    array64.push(17);
    array64.push(0xfffff);
    return array64.getMin();
  }

  function getGetMinMiddle32() returns (uint32){
    delete array32;
    array32.push(1058939);
    array32.push(73);
    array32.push(17);
    array32.push(0xfffff);
    return array32.getMin();
  }

  function getGetMinMiddle16() returns (uint16){
    delete array16;
    array16.push(10589);
    array16.push(73);
    array16.push(17);
    array16.push(0xffff);
    return array16.getMin();
  }

  function getGetMinMiddle8() returns (uint8){
    delete array8;
    array8.push(105);
    array8.push(73);
    array8.push(17);
    array8.push(0xff);
    return array8.getMin();
  }

}
