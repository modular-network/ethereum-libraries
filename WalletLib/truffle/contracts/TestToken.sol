pragma solidity ^0.4.18;

import "./TokenLib.sol";

contract TestToken {
  using TokenLib for TokenLib.TokenStorage;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnerChange(address from, address to);
  event Burn(address indexed burner, uint256 value);
  event MintingClosed(bool mintingClosed);
  event ErrorMsg(string msg);

  TokenLib.TokenStorage token;

  function TestToken(
                address _owner,
                string _name,
                string _symbol,
                uint8 _decimals,
                uint256 _initial_supply,
                bool _allowMinting) 
                public 
  {
    token.init(_owner,_name,_symbol,_decimals,_initial_supply,_allowMinting);
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
