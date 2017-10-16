pragma solidity ^0.4.15;

/**
 * @title EvenDistroCrowdsaleLib
 * @author Majoolr.io
 *
 * version 2.0.1
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The EvenDistroCrowdsale Library provides functionality to create a initial coin offering
 * for a standard token sale with high demand where the amount of ether a single address
 * can contribute is calculated by dividing the sale's contribution cap by the number
 * of addresses who register before the sale starts
 *
 *
 * Test Crowdsale allows for testing in testrpc by allowing a paramater, currtime, to be passed
 * to functions that would normally require a now variable.  This allows testrpc testing
 * without having to add delays in the code to time it perfectly.  This also replaces some require() statements
 * to regular conditional checks to allow for better testing.
 *
 * See https://github.com/Majoolr/ethereum-contracts for an example of how to
 * create a basic ERC20 token.
 *
 * Majoolr works on open source projects in the Ethereum community with the
 * purpose of testing, documenting, and deploying reusable code onto the
 * blockchain to improve security and usability of smart contracts. Majoolr
 * also strives to educate non-profits, schools, and other community members
 * about the application of blockchain technology.
 * For further information: majoolr.io
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
import "./TestCrowdsaleLib.sol";

library TestEvenDistroCrowdsaleLib {
  using BasicMathLib for uint256;
  using TestCrowdsaleLib for TestCrowdsaleLib.CrowdsaleStorage;

  struct EvenDistroCrowdsaleStorage {

  	TestCrowdsaleLib.CrowdsaleStorage base;

    // mapping showing which addresses have registered for the sale. can only be changed by the owner
    mapping (address => bool) isRegistered;

    // mapping to track number of tokens bought
    mapping (address => uint256) tokensBought;

    uint256 numRegistered;   // records how many addresses have registered
    uint256 addressTokenCap;           // cap on how much wei an address can contribute in the sale
    bool staticCap;
  }

  // Indicates when tokens are bought during the sale
  event LogTokensBought(address indexed buyer, uint256 amount, uint256 time);

  // Logs when a buyer has exceeded the address cap and tells them to withdraw their leftover wei
  event LogAddressTokenCapExceeded(address indexed buyer, uint256 amount, string Msg);

  // Logs when a user is registered in the system before the sale
  event LogUserRegistered(address registrant);

  // Logs when a user is unregistered from the system before the sale
  event LogUserUnRegistered(address registrant);

  // Logs when there is an error
  event LogErrorMsg(uint256 amount, string Msg);

  // Logs when there is an increase in the contribution cap per address
  event LogAddressTokenCapChange(uint256 amount, string Msg);

  // Logs when there is a change in price
  event LogTokenPriceChange(uint256 amount, string Msg);

  // Logs when the address cap is initially calculated
  event LogAddressTokenCapCalculated(uint256 saleCap, uint256 numRegistered, uint256 cap, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  function init(EvenDistroCrowdsaleStorage storage self,
                address _owner,
                uint256 _currtime,
                uint256[] _saleData,
                uint256 _fallbackExchangeRate,
                uint256 _capAmountInCents,
                uint256 _endTime,
                uint8 _percentBurn,
                uint256 _initialAddressTokenCap,
                bool _staticCap,
                CrowdsaleToken _token)
  {
    self.base.init(_owner,
                   _currtime,
                   _saleData,
                   _fallbackExchangeRate,
                   _capAmountInCents,
                   _endTime,
                   _percentBurn,
                   _token);

    require(_initialAddressTokenCap > 0);
    self.staticCap = _staticCap;
    self.addressTokenCap = _initialAddressTokenCap;
  }

  /// @dev register user function. can only be called by the owner when a user registers on the web app.
  /// puts their address in the registered mapping and increments the numRegistered
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _registrant address to register for the sale
  function registerUser(EvenDistroCrowdsaleStorage storage self, address _registrant, uint256 currtime) returns (bool) {
    require((msg.sender == self.base.owner) || (msg.sender == address(this)));
    if ((!self.staticCap) && (currtime >= self.base.startTime - 3)) {
      LogErrorMsg(self.base.startTime-1, "Cannot register users within 3 days of the sale!");
      return false;
    }
    if(self.isRegistered[_registrant]) {
      LogErrorMsg(currtime, "Registrant address is already registered for the sale!");
      return false;
    }

    uint256 result;
    bool err;

    self.isRegistered[_registrant] = true;
    (err,result) = self.numRegistered.plus(1);
    require(!err);
    self.numRegistered = result;

    LogUserRegistered(_registrant);

    return true;
  }

  /// @dev registers multiple users at the same time
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _registrants addresses to register for the sale
  function registerUsers(EvenDistroCrowdsaleStorage storage self, address[] _registrants, uint256 currtime) returns (bool) {
    require(msg.sender == self.base.owner);
    bool ok;

    for (uint256 i = 0; i < _registrants.length; i++) {
      ok = registerUser(self,_registrants[i],currtime);
      if(!ok){ LogErrorMsg(currtime, "Multi registration failed"); return false;}
    }
    return true;
  }

  /// @dev Cancels a user's registration status can only be called by the owner when a user cancels their registration.
  /// sets their address field in the registered mapping to false and decrements the numRegistered
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _registrant address to unregister from the sale
  function unregisterUser(EvenDistroCrowdsaleStorage storage self, address _registrant, uint256 currtime) returns (bool) {
    require((msg.sender == self.base.owner) || (msg.sender == address(this)));
    if ((!self.staticCap) && (currtime >= self.base.startTime - 3)) {
      LogErrorMsg(self.base.startTime-1, "Cannot unregister users within 3 days of the sale!");
      return false;
    }
    if(!self.isRegistered[_registrant]) {
      LogErrorMsg(currtime, "Registrant address not registered for the sale!");
      return false;
    }

    uint256 result;
    bool err;

    self.isRegistered[_registrant] = false;
    (err,result) = self.numRegistered.minus(1);
    require(!err);
    self.numRegistered = result;

    LogUserUnRegistered(_registrant);

    return true;
  }

  /// @dev unregisters multiple users at the same time
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _registrants addresses to unregister for the sale
  function unregisterUsers(EvenDistroCrowdsaleStorage storage self, address[] _registrants, uint256 currtime) returns (bool) {
    require(msg.sender == self.base.owner);
    bool ok;

    for (uint256 i = 0; i < _registrants.length; i++) {
      ok = unregisterUser(self,_registrants[i],currtime);
      if(!ok){ LogErrorMsg(currtime, "Multi registration failed"); return false;}
    }
    return true;
  }

  /// @dev function that calculates address cap from the number of users registered
  /// @param self Stored crowdsale from crowdsale contract
  function calculateAddressTokenCap(EvenDistroCrowdsaleStorage storage self, uint256 currtime) internal returns (bool) {
    require(self.numRegistered > 0);
    require(self.base.token.balanceOf(this) > 0);

    if ((currtime > self.base.startTime) || (currtime < (self.base.startTime - 3)) || (self.staticCap))  {
      return false;
    }
    if(self.base.rateSet) { return false; }  //make's sure this can only be called once

    uint256 _baseCap;
    uint256 _calcCap;
    bool err;

    _baseCap = (self.base.token.balanceOf(this))/self.numRegistered; // numRegistered required to be > 0

    for(uint256 i = 0; i < self.base.milestoneTimes.length; i++){
      (err,_calcCap) = self.base.saleData[self.base.milestoneTimes[i]][1].times(_baseCap);
      require(!err);
      self.base.saleData[self.base.milestoneTimes[i]][1] = _calcCap/100;
    }

    self.addressTokenCap = self.base.saleData[self.base.milestoneTimes[0]][1];
    LogAddressTokenCapCalculated(self.base.capAmount, self.numRegistered, self.addressTokenCap, "Address cap was Calculated!");
  }

  /// @dev utility function for the receivePurchase function. returns the lower number
  /// @param a first argument
  /// @param b second argument
  function getMin(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a<b) { return a; } else { return b; }
  }

  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  function receivePurchase(EvenDistroCrowdsaleStorage storage self, uint256 _amount, uint256 currtime) returns (bool) {
    if(msg.sender == self.base.owner) {
      LogErrorMsg(msg.value, "Owner cannot send ether to contract");
      return false;
    }
    if (!self.base.validPurchase(currtime)) {
      return false;
    }
    if ((self.base.ownerBalance + _amount) > self.base.capAmount) {
      LogErrorMsg(msg.value, "buyer ether sent exceeds cap of ether to be raised!");
      return false;
    }
    if(!self.isRegistered[msg.sender]) {
      LogErrorMsg(msg.value, "Buyer is not registered for the sale!");
      return false;
    }

    bool err;
    uint256 result;

    // if the address cap increase interval has passed, update the current day and change the address cap
    if ((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
        (currtime > self.base.milestoneTimes[self.base.currentMilestone + 1]))
    {
      while((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
            (currtime > self.base.milestoneTimes[self.base.currentMilestone + 1]))
      {
        self.base.currentMilestone += 1;
      }

      self.addressTokenCap = self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][1];

      self.base.changeTokenPrice(self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][0]);

      LogAddressTokenCapChange(self.addressTokenCap, "Address cap has increased!");
      LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
  	}

  	uint256 _numTokens; //number of tokens that will be purchased
    uint256 _zeros; //for calculating token
    uint256 _leftoverWei; //wei change for purchaser if they went over the address cap
    uint256 _remainder; //temp calc holder for division remainder and then tokens remaining for the owner
    uint256 _allowedWei;  // tells how much more the buyer can contribute up to their cap
    uint256 _allowedTokens; // number of tokens the buyer is allowed to purchase

    if(self.base.tokenDecimals <= 18) {
      _zeros = 10**(18-uint256(self.base.tokenDecimals));
    } else {
      _zeros = 10**(uint256(self.base.tokenDecimals)-18);
    }

    if(self.addressTokenCap > 0) {
      //_allowedWei represents tokens first, recycle variable to prevent stack depth issues
      _allowedWei = self.addressTokenCap - self.tokensBought[msg.sender];
      if(_allowedWei == 0){
        LogErrorMsg(msg.value, "Cannot but anymore tokens!");
        return false;
      }

      if(self.base.tokenDecimals <= 18){
        _allowedWei = (_allowedWei * _zeros)/self.base.tokensPerEth;
      } else {
        _allowedWei = (_allowedWei * self.base.tokensPerEth)/_zeros;
      }

    } else {
      // if addressTokenCap is zero then there is no cap
      _allowedWei = _amount;
    }

    _allowedWei = getMin(_amount,_allowedWei);
    _leftoverWei = _amount - _allowedWei;

    // Find the number of tokens as a function in wei
    (err,result) = _allowedWei.times(self.base.tokensPerEth);
    require(!err);

    if(self.base.tokenDecimals <= 18){
      _numTokens = result/_zeros;
      if((result % _zeros) > 0){
        _remainder = _allowedWei - ((result-(result%_zeros))/self.base.tokensPerEth);
      }
    } else {
      _numTokens = result*_zeros;
    }

    self.base.leftoverWei[msg.sender] += _leftoverWei+_remainder;
    if(_leftoverWei > 0) {
      LogAddressTokenCapExceeded(msg.sender,self.base.leftoverWei[msg.sender],"Cap Per Address has been exceeded! Please withdraw leftover Wei!");
    }

    // can't overflow because it is under the cap
    self.base.hasContributed[msg.sender] += _allowedWei - _remainder;

    require(_numTokens <= self.base.token.balanceOf(this));

    // calculate the amout of ether in the owners balance and "deposit" it
    self.base.ownerBalance = self.base.ownerBalance + (_allowedWei - _remainder);

    // can't overflow because it will be under the cap
    self.base.withdrawTokensMap[msg.sender] += _numTokens;
    self.tokensBought[msg.sender] += _numTokens;

    //subtract tokens from owner's share
    (err,_remainder) = self.base.withdrawTokensMap[self.base.owner].minus(_numTokens);
    require(!err);
    self.base.withdrawTokensMap[self.base.owner] = _remainder;

    LogTokensBought(msg.sender, _numTokens, now);

    return true;
  }

  ///  Functions "inherited" from CrowdsaleLib library
  function setTokenExchangeRate(EvenDistroCrowdsaleStorage storage self, uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    bool ok = calculateAddressTokenCap(self,_currtime);

    return self.base.setTokenExchangeRate(_exchangeRate, _currtime) && ok;
  }

  function setTokens(EvenDistroCrowdsaleStorage storage self) returns (bool) {
    return self.base.setTokens();
  }

  function getSaleData(EvenDistroCrowdsaleStorage storage self, uint256 timestamp) returns (uint256[3]) {
    return self.base.getSaleData(timestamp);
  }

  function getTokensSold(EvenDistroCrowdsaleStorage storage self) constant returns (uint256) {
    return self.base.getTokensSold();
  }

  function withdrawTokens(EvenDistroCrowdsaleStorage storage self,uint256 currtime) returns (bool) {
    return self.base.withdrawTokens(currtime);
  }

  function withdrawLeftoverWei(EvenDistroCrowdsaleStorage storage self) returns (bool) {
    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(EvenDistroCrowdsaleStorage storage self,uint256 currtime) returns (bool) {
    return self.base.withdrawOwnerEth(currtime);
  }

  function crowdsaleActive(EvenDistroCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleActive(currtime);
  }

  function crowdsaleEnded(EvenDistroCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleEnded(currtime);
  }

  function validPurchase(EvenDistroCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.validPurchase(currtime);
  }
}
