pragma solidity 0.4.19;

import "./BasicMathLib.sol";

contract BasicMathTestContract {
  using BasicMathLib for uint256;

  function getTimes(uint256 a, uint256 b) public pure returns (bool,uint256){
    return a.times(b);
  }

  function getDividedBy(uint256 a, uint256 b) public pure returns (bool,uint256) {
    return a.dividedBy(b);
  }

  function getPlus(uint256 a, uint256 b) public pure returns (bool,uint256) {
    return a.plus(b);
  }

  function getMinus(uint256 a, uint256 b) public pure returns (bool,uint256) {
    return a.minus(b);
  }

}
