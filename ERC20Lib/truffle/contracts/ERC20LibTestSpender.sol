pragma solidity ^0.4.11;

import "./ERC20LibTestContract.sol";

contract ERC20LibTestSpender{

  ERC20LibTestContract t;

  function ERC20LibTestSpender(address testContract) {
    t = ERC20LibTestContract(testContract);
  }

  function spend(address owner, uint256 amount) returns (bool){
    return t.transferFrom(owner, this, amount);
  }

}
