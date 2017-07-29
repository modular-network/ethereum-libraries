
pragma solidity ^0.4.11;

import "./StringUtilsLib.sol";

contract StringUtilsTestContract {
  bytes testBytes;
  event rs(string);

  function getToString() {
    bytes32 func = sha3("toString(bytes)");
    string memory s = "Hello World!";
    bytes memory bs = bytes(s);
    testBytes.length = bs.length + 4;
    for(uint256 i = 0; i<4; i++){
      testBytes[i] = func[i];
    }
    for(i = 4; i<testBytes.length; i++){
      testBytes[i] = bs[i-4];
    }
    uint l = testBytes.length;
    string memory ret = new string(l);
    assembly {
      let iptr := sload(testBytes_slot)
      let optr:= add(ret,0x20)
      callcode(10000,0x5782168d8d642ead398c991534fb9ea7c1f68aac,0,iptr,l,optr,l)
      pop
    }
    rs("Test");
  }
/*
  function getDividedBy(uint256 a, uint256 b) returns (bool,uint256) {
    return a.dividedBy(b);
  }

  function getPlus(uint256 a, uint256 b) returns (bool,uint256) {
    return a.plus(b);
  }

  function getMinus(uint256 a, uint256 b) returns (bool,uint256) {
    return a.minus(b);
  }
*/
}
