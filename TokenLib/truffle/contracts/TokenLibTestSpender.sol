pragma solidity ^0.4.15;

import "./TokenLibTestContract.sol";

contract TokenLibTestSpender{

  TokenLibTestContract t;

  function TokenLibTestSpender(address testContract) public {
    t = TokenLibTestContract(testContract);
  }

  function spend(address owner, uint256 amount) public returns (bool){
    return t.transferFrom(owner, this, amount);
  }

  function changeOwnerBack(address newOwner) public {
    t.changeOwner(newOwner);
  }

}
