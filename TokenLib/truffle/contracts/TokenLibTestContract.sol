pragma solidity ^0.4.15;

import "./TokenLib.sol";

contract TokenLibTestContract {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage token;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnerChange(address from, address to);
  event Burn(address indexed burner, uint256 value);
  event MintingClosed(bool mintingClosed);

  function TokenLibTestContract(address owner,
                                string name,
                                string symbol,
                                uint8 decimals,
                                uint256 initialSupply,
                                bool allowMinting) public
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function owner()  public view returns (address) {
    return token.owner;
  }

  function name()  public view returns (string) {
    return token.name;
  }

  function symbol()  public view returns (string) {
    return token.symbol;
  }

  function decimals()  public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply()  public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply()  public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who)  public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address _owner, address _spender)  public view returns (uint256) {
    return token.allowance(_owner, _spender);
  }

  function transfer(address to, uint value)  public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value)  public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value)  public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint valueChange, bool increase)  public returns (bool ok) {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner)  public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function mintToken(uint amount)  public returns (bool ok) {
    return token.mintToken(amount);
  }

  function closeMint()  public returns (bool ok) {
    return token.closeMint();
  }

  function burnToken(uint amount)  public returns (bool ok) {
    return token.burnToken(amount);
  }
}
