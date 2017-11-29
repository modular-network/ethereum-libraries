pragma solidity ^0.4.18;

import "./ERC20Lib.sol";

contract TestToken {
  using ERC20Lib for ERC20Lib.TokenStorage;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event ErrorMsg(string msg);

  ERC20Lib.TokenStorage token;

  uint public INITIAL_SUPPLY = 10;

  function TestToken() public {
    token.init(INITIAL_SUPPLY);
  }

  function totalSupply() public view returns (uint) {
    return token.totalSupply;
  }

  function balanceOf(address who) public view returns (uint) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) public returns (bool ok) {
    return token.approve(spender, value);
  }

}
