pragma solidity ^0.4.15;

import "./TokenLib.sol";

contract TokenLibTestContract {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage token;

  function TokenLibTestContract(address owner,
                                string name,
                                string symbol,
                                uint8 decimals,
                                uint256 initialSupply,
                                bool allowMinting)
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function owner() constant returns (address) {
    return token.owner;
  }

  function name() constant returns (string) {
    return token.name;
  }

  function symbol() constant returns (string) {
    return token.symbol;
  }

  function decimals() constant returns (uint8) {
    return token.decimals;
  }

  function totalSupply() constant returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() constant returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) constant returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) constant returns (uint256) {
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

  function approveChange(address spender, uint valueChange, bool increase) returns (bool ok) {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function mintToken(uint amount) returns (bool ok) {
    return token.mintToken(amount);
  }

  function closeMint() returns (bool ok) {
    return token.closeMint();
  }

  function burnToken(uint amount) returns (bool ok) {
    return token.burnToken(amount);
  }
}
