pragma solidity ^0.4.11;

/**
 * @title ERC20Lib
 * @author Majoolr.io
 *
 * version 1.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The ERC20 Library is inspired by advice offered by Aragon at
 * https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736 .
 * That version of the library has been modified to provide error messages
 * rather than throw errors. This allows the developer to decide how she wants
 * handle failed transactions. The developer can choose to assert a true return
 * value and allow automatic reversion of state changes or, if no state changes
 * have been made, she can trigger an event message to give the user a
 * descriptive outcome.
 *
 * Majoolr works on open source projects in the Ethereum community with the
 * purpose of testing, documenting, and deploying reusable code onto the
 * blockchain to improve security and usability of smart contracts. Majoolr
 * also strives to educate non-profits, schools, and other community members
 * about the application of blockchain technology.
 * For further information: majoolr.io, aragon.one
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import "./BasicMathLib.sol";

library ERC20Lib {
  using BasicMathLib for uint256;

  struct TokenStorage {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint totalSupply;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event ErrorMsg(string msg);

  /// @dev Called by the Standard Token upon creation.
  /// @param self Stored token from token contract
  /// @param _initial_supply The initial token supply
  function init(TokenStorage storage self, uint256 _initial_supply) {
    self.totalSupply = _initial_supply;
    self.balances[msg.sender] = _initial_supply;
  }

  /// @dev Transfer tokens from caller's account to another account.
  /// @param self Stored token from token contract
  /// @param _to Address to send tokens
  /// @param _value Number of tokens to send
  /// @return success True if completed, false otherwise
  function transfer(TokenStorage storage self, address _to, uint256 _value) returns (bool success) {
    bool err;
    uint256 balance;

    (err,balance) = self.balances[msg.sender].minus(_value);
    if(err) {
      ErrorMsg("Balance too low for transfer");
      return false;
    }
    self.balances[msg.sender] = balance;
    //It's not possible to overflow token supply
    self.balances[_to] = self.balances[_to] + _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Authorized caller transfers tokens from one account to another
  /// @param self Stored token from token contract
  /// @param _from Address to send tokens from
  /// @param _to Address to send tokens to
  /// @param _value Number of tokens to send
  /// @return success True if completed, false otherwise
  function transferFrom(TokenStorage storage self,
                        address _from,
                        address _to,
                        uint256 _value)
                        returns (bool success) {
    var _allowance = self.allowed[_from][msg.sender];
    bool err;
    uint256 balanceOwner;
    uint256 balanceSpender;

    (err,balanceOwner) = self.balances[_from].minus(_value);
    if(err) {
      ErrorMsg("Balance too low for transfer");
      return false;
    }

    (err,balanceSpender) = _allowance.minus(_value);
    if(err) {
      ErrorMsg("Transfer exceeds allowance");
      return false;
    }
    self.balances[_from] = balanceOwner;
    self.allowed[_from][msg.sender] = balanceSpender;
    self.balances[_to] = self.balances[_to] + _value;

    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Retrieve token balance for an account
  /// @param self Stored token from token contract
  /// @param _owner Address to retrieve balance of
  /// @return balance The number of tokens in the subject account
  function balanceOf(TokenStorage storage self, address _owner) constant returns (uint256 balance) {
    return self.balances[_owner];
  }

  /// @dev Authorize an account to send tokens on caller's behalf
  /// @param self Stored token from token contract
  /// @param _spender Address to authorize
  /// @param _value Number of tokens authorized account may send
  /// @return success True if completed, false otherwise
  function approve(TokenStorage storage self, address _spender, uint256 _value) returns (bool success) {
    self.allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Remaining tokens third party spender has to send
  /// @param self Stored token from token contract
  /// @param _owner Address of token holder
  /// @param _spender Address of authorized spender
  /// @return remaining Number of tokens spender has left in owner's account
  function allowance(TokenStorage storage self, address _owner, address _spender) constant returns (uint256 remaining) {
    return self.allowed[_owner][_spender];
  }
}
