pragma solidity ^0.4.18;

/**
 * @title VestingLib
 * @author Modular.network
 *
 * version 1.0.1
 * Copyright (c) 2017 Modular, LLC
 * The MIT License (MIT)
 * https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE
 *
 * Library for vesting tokens to a group of addresses.  The library only handles
 * one token at a time, with a linear vesting schedule for a set period of time
 *
 * Modular works on open source projects in the Ethereum community with the
 * purpose of testing, documenting, and deploying reusable code onto the
 * blockchain to improve security and usability of smart contracts. Modular
 * also strives to educate non-profits, schools, and other community members
 * about the application of blockchain technology.
 * For further information: modular.network
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
import "./TokenLib.sol";
import "./CrowdsaleToken.sol";

library VestingLib {
  using BasicMathLib for uint256;

  struct VestingStorage {
    address owner;

    uint256 totalSupply;     // total supply of ETH or tokens
    uint256 contractBalance; // current balance of the contract
    bool isToken;            // false for ETH, true for token

    uint256 startTime;       // timestamp when vesting starts
    uint256 endTime;         // timestamp when vesting is complete

    uint256 numRegistered;   // number of addresses registered for the vesting

    uint256 timeInterval;    // interval between vesting
    uint256 percentPerInterval; // percentage of the total released every interval

    // for each address, 0-index is the amount being held, 1-index is the bonus.
    // if the bonus amount is > 0, any withdrawal before endTime will result
    // in the total amount being withdrawn without the bonus
    mapping (address => uint256[2]) holdingAmount;

    // shows how much an address has already withdrawn from the vesting contract
    mapping (address => uint256) hasWithdrawn;
  }

  // Generic Error message, error code and string
  event LogErrorMsg(uint256 amount, string Msg);

  // Logs when a user is registered in the system for vesting
  event LogUserRegistered(address registrant, uint256 vestAmount, uint256 bonus);

  // Logs when a user is unregistered from the system
  event LogUserUnRegistered(address registrant);

  // Logs when a user replaces themselves with a different beneficiary
  event LogRegistrationReplaced(address currentRegistrant, address newRegistrant, uint256 amountWithdrawn);

  // Logs when a user withdraws their ETH from vesting
  event LogETHWithdrawn(address beneficiary, uint256 amount);

  // Logs when a user withdraws their tokens from the contract
  event LogTokensWithdrawn(address beneficiary, uint256 amount);

  /// @dev Called by the token vesting contract upon creation.
  /// @param self Stored token from token contract
  /// @param _owner the owner of the vesting contract
  /// @param _isToken indicates if the vesting is for tokens or ETH
  /// @param _startTime the start time of the vesting (UNIX timestamp)
  /// @param _endTime the end time of the vesting     (UNIX timestamp)
  /// @param _numReleases number of times during vesting that the contract releases coins
  function init(VestingStorage storage self,
                address _owner,
                bool _isToken,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _numReleases) public
  {
    require(self.owner == 0);
    require(self.totalSupply == 0);
    require(_owner != 0);
    require(_startTime > now);
    require(_endTime > _startTime);
    require(_numReleases > 0);
    require(_numReleases <= 100);

    self.owner = _owner;
    self.isToken = _isToken;
    self.startTime = _startTime;
    self.endTime = _endTime;
    self.timeInterval = (_endTime - _startTime)/_numReleases;
    require(self.timeInterval > 0);
    self.percentPerInterval = 100000/_numReleases;
  }

  /// @dev function owner has to call before the vesting starts to initialize the ETH balance of the contract.
  /// @param self Stored vesting from vesting contract
  /// @param _balance the balance that is being vested.  msg.value from the contract call.
  function initializeETHBalance(VestingStorage storage self, uint256 _balance) public returns (bool) {
    require(msg.sender == self.owner);
    require(now < self.startTime);
    require(_balance != 0);
    require(!self.isToken);
    require(self.totalSupply == 0);

    self.totalSupply = _balance;
    self.contractBalance = _balance;

    return true;
  }

  /// @dev function owner has to call before the vesting starts to initialize the token balance of the contract.
  /// @param self Stored vesting from vesting contract
  /// @param _balance the balance that is being vested.  owner has to have sent tokens to the contract before calling this function
  function initializeTokenBalance(VestingStorage storage self, CrowdsaleToken token, uint256 _balance) public returns (bool) {
    require(msg.sender == self.owner);
    require(now < self.startTime);
    require(_balance != 0);
    require(self.isToken);
    require(token.balanceOf(this) == _balance);
    require(self.totalSupply == 0);

    self.totalSupply = _balance;
    self.contractBalance = _balance;

    return true;
  }

  /// @dev register user function, can only be called by the owner. registers amount
  /// of vesting into the address and reduces contractBalance
  /// @param self Stored vesting from vesting contract
  /// @param _registrant address to be registered for the vesting
  /// @param _vestAmount amount of ETH or tokens to vest for address
  /// @param _bonus amount of bonus tokens or eth if no withdrawal prior to endTime
  function registerUser(VestingStorage storage self,
                        address _registrant,
                        uint256 _vestAmount,
                        uint256 _bonus) public returns (bool)
  {
    require((msg.sender == self.owner) || (msg.sender == address(this)));
    if (now >= self.startTime) {
      LogErrorMsg(self.startTime,"Can only register users before the vesting starts!");
      return false;
    }
    if(self.holdingAmount[_registrant][0] > 0) {
      LogErrorMsg(0,"Registrant address is already registered for the vesting!");
      return false;
    }
    if(_bonus > _vestAmount){
      LogErrorMsg(_bonus,"Bonus is larger than vest amount, please reduce bonus!");
      return false;
    }

    uint256 _totalAmount;
    uint256 result;
    bool err;

    (err, _totalAmount) = _vestAmount.plus(_bonus);
    require(!err);

    (err, result) = self.contractBalance.minus(_totalAmount);
    require(!err);

    self.contractBalance = result;
    self.holdingAmount[_registrant][0] = _vestAmount;
    self.holdingAmount[_registrant][1] = _bonus;

    (err,result) = self.numRegistered.plus(1);
    require(!err);
    self.numRegistered = result;

    LogUserRegistered(_registrant, _vestAmount, _bonus);

    return true;
  }

  /// @dev registers multiple users at the same time. each registrant must be
  /// receiving the same amount of tokens or ETH
  /// @param self Stored vesting from vesting contract
  /// @param _registrants addresses to register for the vesting
  /// @param _vestAmount amount of ETH or tokens to vest
  /// @param _bonus amount of ETH or token bonus
  function registerUsers(VestingStorage storage self,
                         address[] _registrants,
                         uint256 _vestAmount,
                         uint256 _bonus) public returns (bool)
  {
    require(msg.sender == self.owner);
    bool ok;

    for (uint256 i = 0; i < _registrants.length; i++) {
      ok = registerUser(self,_registrants[i], _vestAmount, _bonus);
    }
    return ok;
  }

  /// @dev Cancels a user's registration status can only be called by the owner
  /// when a user cancels their registration. sets their address field in the
  /// holding amount mapping to 0, decrements the numRegistered, and adds amount
  /// back into contractBalance
  /// @param self Stored vesting from vesting contract
  function unregisterUser(VestingStorage storage self, address _registrant) public returns (bool) {
    require((msg.sender == self.owner) || (msg.sender == address(this)));
    if (now >= self.startTime) {
      LogErrorMsg(self.startTime, "Can only register and unregister users before the vesting starts!");
      return false;
    }

    uint256 _totalHolding;
    uint256 result;
    bool err;

    _totalHolding = self.holdingAmount[_registrant][0] + self.holdingAmount[_registrant][1];
    if(_totalHolding == 0) {
      LogErrorMsg(0, "Registrant address not registered for the vesting!");
      return false;
    }

    self.holdingAmount[_registrant][0] = 0;
    self.holdingAmount[_registrant][1] = 0;
    self.contractBalance += _totalHolding;

    (err,result) = self.numRegistered.minus(1);
    require(!err);
    self.numRegistered = result;

    LogUserUnRegistered(_registrant);

    return true;
  }

  /// @dev unregisters multiple users at the same time
  /// @param self Stored vesting from vesting contract
  /// @param _registrants addresses to unregister for the vesting
  function unregisterUsers(VestingStorage storage self, address[] _registrants) public returns (bool) {
    require(msg.sender == self.owner);
    bool ok;

    for (uint256 i = 0; i < _registrants.length; i++) {
      ok = unregisterUser(self,_registrants[i]);
    }
    return ok;
  }

  /// @dev allows a participant to replace themselves in the vesting schedule with a new address
  /// @param self Stored vesting from vesting contract
  /// @param _replacementRegistrant new address to replace the caller with
  function swapRegistration(VestingStorage storage self, address _replacementRegistrant) public returns (bool) {
    require(_replacementRegistrant != 0);
    require(self.holdingAmount[_replacementRegistrant][0] == 0);

    uint256 _vestAmount = self.holdingAmount[msg.sender][0];
    uint256 _bonus = self.holdingAmount[msg.sender][1];
    uint256 _withdrawnAmount = self.hasWithdrawn[msg.sender];
    require(_vestAmount > 0);

    self.holdingAmount[msg.sender][0] = 0;
    self.holdingAmount[msg.sender][1] = 0;
    self.hasWithdrawn[msg.sender] = 0;
    self.holdingAmount[_replacementRegistrant][0] = _vestAmount;
    self.holdingAmount[_replacementRegistrant][1] = _bonus;
    self.hasWithdrawn[_replacementRegistrant] = _withdrawnAmount;

    LogRegistrationReplaced(msg.sender, _replacementRegistrant, self.hasWithdrawn[_replacementRegistrant]);

    return true;

  }

  /// @dev calculates the number of tokens or ETH available for the beneficiary to withdraw
  /// @param self Stored vesting from vesting contract
  /// @param _beneficiary the sender, who will be withdrawing their balance
  function calculateWithdrawal(VestingStorage storage self, address _beneficiary) internal view returns (uint256) {
    require(_beneficiary != 0);
    require(self.holdingAmount[_beneficiary][0] > 0);
    require(self.numRegistered > 0);
    bool err;

    // figure out how many intervals have passed since the start
    uint256 _numIntervals = (now-self.startTime)/self.timeInterval;

    // multiply that by the percentage released every interval
    // calculate the amount released by this time
    uint256 _amountReleased = ((_numIntervals*self.percentPerInterval)*self.holdingAmount[_beneficiary][0])/100000;

    // subtract the amount that has already been withdrawn
    (err, _amountReleased) = _amountReleased.minus(self.hasWithdrawn[_beneficiary]);

    return _amountReleased;
  }

  /// @dev allows participants to withdraw their vested ETH
  /// @param self Stored vesting from vesting contract
  function withdrawETH(VestingStorage storage self) public returns (bool) {
    require(now > self.startTime);
    require(!self.isToken);
    bool ok;
    bool err;
    uint256 _withdrawAmount;

    if((now < self.endTime) && (self.holdingAmount[msg.sender][1] > 0)){
      // if there is a bonus and it's before the endTime, cancel the bonus
      _withdrawAmount = calculateWithdrawal(self, msg.sender);
      uint256 _bonusAmount = self.holdingAmount[msg.sender][1];
      //self.holdingAmount[msg.sender][0] = 0;
      self.holdingAmount[msg.sender][1] = 0;

      // add bonus eth back into the contract balance
      self.contractBalance += _bonusAmount;
    } else {
      if(now > self.endTime){
        // if it's past the endTime then send everything left
        _withdrawAmount = self.holdingAmount[msg.sender][0] + self.holdingAmount[msg.sender][1];
        (ok, _withdrawAmount) = _withdrawAmount.minus(self.hasWithdrawn[msg.sender]);
        require(!err);

        self.holdingAmount[msg.sender][0] = 0;
        self.holdingAmount[msg.sender][1] = 0;
      } else {
        // if we're here then it's before the endTime and no bonus, need to calculate
        _withdrawAmount = calculateWithdrawal(self, msg.sender);
      }
    }

    self.hasWithdrawn[msg.sender] += _withdrawAmount;

    // transfer ETH to the sender
    msg.sender.transfer(_withdrawAmount);

    LogETHWithdrawn(msg.sender,_withdrawAmount);
    return true;
  }

  /// @dev allows participants to withdraw their vested tokens
  /// @param self Stored vesting from vesting contract
  /// @param token the token contract that is being withdrawn
  function withdrawTokens(VestingStorage storage self,CrowdsaleToken token) public returns (bool) {
    require(now > self.startTime);
    require(self.isToken);
    bool ok;
    bool err;
    uint256 _withdrawAmount;

    if((now < self.endTime) && (self.holdingAmount[msg.sender][1] > 0)){
      // if there is a bonus and it's before the endTime, cancel the bonus and send tokens
      _withdrawAmount = calculateWithdrawal(self, msg.sender);
      uint256 _bonusAmount = self.holdingAmount[msg.sender][1];

      self.holdingAmount[msg.sender][1] = 0;
      ok = token.burnToken(_bonusAmount);
      require(ok);
    } else {
      if(now > self.endTime){
        // if it's past the endTime then send everything left
        _withdrawAmount = self.holdingAmount[msg.sender][0] + self.holdingAmount[msg.sender][1];
        (ok, _withdrawAmount) = _withdrawAmount.minus(self.hasWithdrawn[msg.sender]);
        require(!err);

        self.holdingAmount[msg.sender][0] = 0;
        self.holdingAmount[msg.sender][1] = 0;
      } else {
        // if we're here then it's before the endTime and no bonus, need to calculate
        _withdrawAmount = calculateWithdrawal(self, msg.sender);
      }
    }

    self.hasWithdrawn[msg.sender] += _withdrawAmount;

    // transfer tokens to the sender
    ok = token.transfer(msg.sender, _withdrawAmount);
    require(ok);

    LogTokensWithdrawn(msg.sender,_withdrawAmount);
    return true;
  }

  /// @dev allows the owner to send vested ETH to participants
  /// @param self Stored vesting from vesting contract
  /// @param _beneficiary registered address to send the ETH to
  function sendETH(VestingStorage storage self, address _beneficiary) public returns (bool) {
    require(now > self.startTime);
    require(msg.sender == self.owner);
    require(!self.isToken);
    bool ok;
    bool err;
    uint256 _withdrawAmount;

    if((now < self.endTime) && (self.holdingAmount[_beneficiary][1] > 0)){
      // if there is a bonus and it's before the endTime, cancel the bonus
      _withdrawAmount = calculateWithdrawal(self, _beneficiary);
      uint256 _bonusAmount = self.holdingAmount[_beneficiary][1];

      self.holdingAmount[_beneficiary][1] = 0;

      // add bonus eth back into the contract balance
      self.contractBalance += _bonusAmount;
    } else {
      if(now > self.endTime){
        // if it's past the endTime then send everything left
        _withdrawAmount = self.holdingAmount[_beneficiary][0] + self.holdingAmount[_beneficiary][1];
        (ok, _withdrawAmount) = _withdrawAmount.minus(self.hasWithdrawn[_beneficiary]);
        require(!err);

        self.holdingAmount[_beneficiary][0] = 0;
        self.holdingAmount[_beneficiary][1] = 0;
      } else {
        // if we're here then it's before the endTime and no bonus, need to calculate
        _withdrawAmount = calculateWithdrawal(self, _beneficiary);
      }
    }

    self.hasWithdrawn[_beneficiary] += _withdrawAmount;

    // transfer ETH to the _beneficiary
    _beneficiary.transfer(_withdrawAmount);

    LogETHWithdrawn(_beneficiary,_withdrawAmount);
    return true;
  }

  /// @dev allows the owner to send vested tokens to participants
  /// @param self Stored vesting from vesting contract
  /// @param token the token contract that is being withdrawn
  /// @param _beneficiary registered address to send the tokens to
  function sendTokens(VestingStorage storage self,CrowdsaleToken token, address _beneficiary) public returns (bool) {
    require(now > self.startTime);
    require(msg.sender == self.owner);
    require(self.isToken);
    bool ok;
    bool err;
    uint256 _withdrawAmount;

    if((now < self.endTime) && (self.holdingAmount[_beneficiary][1] > 0)){
      // if there is a bonus and it's before the endTime, cancel the bonus
      _withdrawAmount = calculateWithdrawal(self, _beneficiary);
      uint256 _bonusAmount = self.holdingAmount[_beneficiary][1];
      
      self.holdingAmount[msg.sender][1] = 0;
      ok = token.burnToken(_bonusAmount);
    } else {
      if(now > self.endTime){
        // if it's past the endTime then send everything left
        _withdrawAmount = self.holdingAmount[_beneficiary][0] + self.holdingAmount[_beneficiary][1];
        (ok, _withdrawAmount) = _withdrawAmount.minus(self.hasWithdrawn[_beneficiary]);
        require(!err);

        self.holdingAmount[_beneficiary][0] = 0;
        self.holdingAmount[_beneficiary][1] = 0;
      } else {
        // if we're here then it's before the endTime and no bonus, need to calculate
        _withdrawAmount = calculateWithdrawal(self, _beneficiary);
      }
    }

    self.hasWithdrawn[_beneficiary] += _withdrawAmount;

    // transfer tokens to the beneficiary
    ok = token.transfer(_beneficiary, _withdrawAmount);
    require(ok);

    LogTokensWithdrawn(_beneficiary,_withdrawAmount);
    return true;
  }

  /// @dev Allows the owner to withdraw any ETH left in the contractBalance
  /// @param self Stored vesting from vesting contract
  function ownerWithdrawExtraETH(VestingStorage storage self) public returns (bool) {
    require(msg.sender == self.owner);
    require(now > self.endTime);
    require(!self.isToken);

    uint256 _contractBalance = this.balance;
    self.contractBalance = 0;

    self.owner.transfer(_contractBalance);
    LogETHWithdrawn(self.owner,_contractBalance);

    return true;
  }

  /// @dev Allows the owner to withdraw any tokens left in the contractBalance
  /// @param self Stored vesting from vesting contract
  function ownerWithdrawExtraTokens(VestingStorage storage self, CrowdsaleToken token) public returns (bool) {
    require(msg.sender == self.owner);
    require(now > self.endTime);
    require(self.isToken);

    uint256 _contractBalance = token.balanceOf(this);
    self.contractBalance = 0;

    token.transfer(self.owner,_contractBalance);
    LogTokensWithdrawn(self.owner,_contractBalance);

    return true;
  }

  /// @dev Returns the percentage of the vesting that has been released at the current moment
  function getPercentReleased(VestingStorage storage self) public view returns (uint256) {
    require(now > self.startTime);
    return (self.percentPerInterval * ((now-self.startTime)/self.timeInterval))/1000;
  }
}
