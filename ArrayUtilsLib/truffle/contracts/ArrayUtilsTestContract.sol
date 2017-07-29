pragma solidity ^0.4.11;

import "./ArrayUtilsLib.sol";

contract ArrayUtilsTestContract {
  using ArrayUtilsLib for uint256[];

  uint256[] array;

  function getSumElements() returns (uint256){
    delete array;
    array.push(2);
    array.push(10);
    array.push(0);
    array.push(10342);
    return array.sumElements();
  }

  function getGetMaxMiddle() returns (uint256){
    delete array;
    array.push(2);
    array.push(0);
    array.push(1058939);
    array.push(0xfffff);
    return array.getMax();
  }

  function getGetMaxLast() returns (uint256){
    delete array;
    array.push(2);
    array.push(0);
    array.push(105893);
    array.push(0xfffff);
    return array.getMax();
  }

  function getGetMaxFirst() returns (uint256){
    delete array;
    array.push(1058939);
    array.push(0);
    array.push(2);
    array.push(0xfffff);
    return array.getMax();
  }

  function getSortedIndexOf() returns (bool,uint256){
    delete array;
    array.push(1);
    array.push(3);
    array.push(4);
    array.push(7);
    array.push(9);
    array.push(1095);
    return array.indexOf(7,true);
  }

  function getUnsortedIndexOf() returns (bool,uint256) {
    delete array;
    array.push(7);
    array.push(0xffff);
    array.push(3);
    array.push(1);
    array.push(9);
    array.push(1095);
    return array.indexOf(1095,false);
  }

  function getNoIndexOf() returns (bool,uint256) {
    delete array;
    array.push(1);
    array.push(3);
    array.push(4);
    array.push(7);
    array.push(9);
    array.push(1095);
    return array.indexOf(10,false);
  }

  function getHeapSort() returns (uint256[10] memory r){
    delete array;
    array.push(3);
    array.push(1);
    array.push(9);
    array.push(7);
    array.push(4);
    array.push(4);
    array.push(0xff3);
    array.push(0);
    array.push(1095);
    array.push(1);
    array.heapSort();
    for(uint256 i = 0; i<array.length; i++){
      r[i] = array[i];
    }
  }
}
