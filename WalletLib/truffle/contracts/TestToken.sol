pragma solidity ^0.4.11;

import "./ERC20Lib.sol";

contract TestToken {
  using ERC20Lib for ERC20Lib.TokenStorage;

  ERC20Lib.TokenStorage token;

  uint public INITIAL_SUPPLY = 10;

  function TestToken() {
    token.init(INITIAL_SUPPLY);
  }

  function totalSupply() constant returns (uint) {
    return token.totalSupply;
  }

  function balanceOf(address who) constant returns (uint) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) constant returns (uint) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) returns (bool ok) {
    return token.approve(spender, value);
  }

}
