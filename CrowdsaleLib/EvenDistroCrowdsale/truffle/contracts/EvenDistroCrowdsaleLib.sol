pragma solidity ^0.4.18;

/**
 * @title EvenDistroCrowdsaleLib
 * @author Modular Inc, https://modular.network
 *
 * version 2.2.1
 * Copyright (c) 2017 Modular Inc
 * The MIT License (MIT)
 * https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE
 *
 * The EvenDistroCrowdsale Library provides functionality to create a initial coin offering
 * for a standard token sale with high demand where the amount of ether a single address
 * can contribute is calculated by dividing the sale's contribution cap by the number
 * of addresses who register before the sale starts
 *
 * Modular provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: modular.network
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
import "./CrowdsaleLib.sol";

library EvenDistroCrowdsaleLib {
  using BasicMathLib for uint256;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  struct EvenDistroCrowdsaleStorage {

  	CrowdsaleLib.CrowdsaleStorage base; // base storage from CrowdsaleLib

    // mapping showing which addresses have registered for the sale. can only be changed by the owner
    mapping (address => bool) isRegistered;

    // tracks the total number of tokens bought for each address
    mapping(address => uint256) tokensBought;

    uint256 numRegistered; // records how many addresses have registered
    uint256 addressTokenCap; // cap on how much wei an address can contribute in the sale
    bool staticCap; // true if the given address cap amounts are set on initialization
  }


  event LogTokensBought(address buyer, uint256 amount);
  event LogTokenPriceChange(uint256 amount, string Msg);
  event LogErrorMsg(uint256 amount, string Msg);

  // Logs when a user is registered in the system before the sale
  event LogUserRegistered(address registrant);

  // Logs when a user is unregistered from the system before the sale
  event LogUserUnRegistered(address registrant);

  // Logs when there is an error with user registration
  event LogRegError(address user, string Msg);

  // Logs when there is an increase in the contribution cap per address
  event LogAddressTokenCapChange(uint256 amount, string Msg);

  // Logs when the address cap is initially calculated
  event LogAddressTokenCapCalculated(uint256 numRegistered, uint256 cap, string Msg);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in tokens/ETH at that time,
  /// 3 is address purchase cap at that time, 0 if no address cap
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _staticCap Whether or not the address cap is going to be static
  /// @param _token Token being sold
  function init(EvenDistroCrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _endTime,
                uint8 _percentBurn,
                uint256 _initialAddressTokenCap,
                bool _staticCap,
                CrowdsaleToken _token)
                public
  {
  	self.base.init(_owner,
                   _saleData,
                   _endTime,
                   _percentBurn,
                   _token);

    self.addressTokenCap = _initialAddressTokenCap;
    self.staticCap = _staticCap;
  }

  /// @dev register user function. can only be called by the owner when a user registers on the web app.
  /// puts their address in the registered mapping and increments the numRegistered
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _registrant address to be registered for the sale
  function registerUser(EvenDistroCrowdsaleStorage storage self, address _registrant)
                        public
                        returns (bool)
  {
    require((msg.sender == self.base.owner) || (msg.sender == address(this)));
    // if the change interval is 0, then registration is allowed throughout the
    // sale since a cap doesn't need to be calculated
    if ((!self.staticCap) && (now >= self.base.startTime - 2 hours)) {
      LogRegError(_registrant, "Can only register users earlier than 2 hours before the sale!");
      return false;
    }
    if(self.isRegistered[_registrant]) {
      LogRegError(_registrant, "Registrant address is already registered for the sale!");
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
  function registerUsers(EvenDistroCrowdsaleStorage storage self, address[] _registrants)
                         public
                         returns (bool)
  {
    require(msg.sender == self.base.owner);

    for (uint256 i = 0; i < _registrants.length; i++) {
      registerUser(self,_registrants[i]);
    }
    return true;
  }

  /// @dev Cancels a user's registration status can only be called by the owner when a user cancels their registration.
  /// sets their address field in the registered mapping to false and decrements the numRegistered
  /// @param self Stored crowdsale from crowdsale contract
  function unregisterUser(EvenDistroCrowdsaleStorage storage self, address _registrant)
                          public
                          returns (bool)
  {
    require((msg.sender == self.base.owner) || (msg.sender == address(this)));
    if ((!self.staticCap) && (now >= self.base.startTime - 2 hours)) {
      LogRegError(_registrant, "Can only unregister users earlier than 2 hours before the sale!");
      return false;
    }
    if(!self.isRegistered[_registrant]) {
      LogRegError(_registrant, "Registrant address not registered for the sale!");
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
  function unregisterUsers(EvenDistroCrowdsaleStorage storage self, address[] _registrants)
                           public
                           returns (bool)
  {
    require(msg.sender == self.base.owner);

    for (uint256 i = 0; i < _registrants.length; i++) {
      unregisterUser(self,_registrants[i]);
    }
    return true;
  }

  /// @dev function that calculates address cap from the number of users registered
  /// @param self Stored crowdsale from crowdsale contract
  function calculateAddressTokenCap(EvenDistroCrowdsaleStorage storage self)
                                    internal
                                    returns (bool)
  {
    require(self.numRegistered > 0);
    require(self.base.token.balanceOf(this) > 0);

    if (self.staticCap)  {
      return false;
    }
    require(!self.base.tokensSet);  // makes sure this can only be called once

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
    LogAddressTokenCapCalculated(self.numRegistered, self.addressTokenCap, "Address cap was Calculated!");
  }

  /// @dev utility function for the receivePurchase function. returns the lower number
  /// @param a first argument
  /// @param b second argument
  function getMin(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a<b) { return a; } else { return b; }
  }


  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  /// @return true on succesful purchase
  function receivePurchase(EvenDistroCrowdsaleStorage storage self, uint256 _amount)
                           public
                           returns (bool)
  {
    require(msg.sender != self.base.owner);
    require(self.base.validPurchase());
    require(self.isRegistered[msg.sender]);

  	// if the address cap increase interval has passed, update the current day and change the address cap
  	if ((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
        (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
    {
      while((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
            (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
      {
        self.base.currentMilestone += 1;
      }

      self.addressTokenCap = self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][1];

      self.base.changeTokenPrice(self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][0]);

      LogAddressTokenCapChange(self.addressTokenCap, "Address cap has increased!");
      LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
  	}

    uint256 _numTokens; //number of tokens that will be purchased
    uint256 _newBalance; //the new balance of the owner of the crowdsale
    uint256 _weiTokens; //temp calc holder
    uint256 _leftoverWei; //wei change for purchaser
    uint256 _remainder; //temp calc holder
    uint256 _allowedWei;  // tells how much more the buyer can contribute up to their cap
    bool err;

    if(self.addressTokenCap > 0) {
      //_allowedWei represents tokens first, recycle variable to prevent stack depth issues
      _allowedWei = self.addressTokenCap - self.tokensBought[msg.sender];

      (err, _allowedWei) = _allowedWei.times(1000000000000000000);
      require(!err);

      _allowedWei = _allowedWei/self.base.tokensPerEth;
    } else {
      // if addressTokenCap is zero then there is no cap
      _allowedWei = _amount;
    }
    require(_allowedWei > 0);
    _allowedWei = getMin(_amount,_allowedWei);
    _leftoverWei = _leftoverWei + (_amount - _allowedWei);

    // Find the number of tokens as a function in wei
    (err,_weiTokens) = _allowedWei.times(self.base.tokensPerEth);
    require(!err);

    _numTokens = _weiTokens / 1000000000000000000;
    _remainder = _weiTokens % 1000000000000000000;
    _remainder = _remainder / self.base.tokensPerEth;
    _leftoverWei = _leftoverWei + _remainder;
    _amount = _amount - _remainder;
    self.base.leftoverWei[msg.sender] += _leftoverWei;

    // can't overflow because it is under the cap
    self.base.hasContributed[msg.sender] += _allowedWei - _remainder;

    assert(_numTokens <= self.base.token.balanceOf(this));

    // calculate the amount of ether in the owners balance
    (err,_newBalance) = self.base.ownerBalance.plus(_amount);
    require(!err);

    self.base.ownerBalance = _newBalance;   // "deposit" the amount

    // can't overflow because it will be under the cap
    self.base.withdrawTokensMap[msg.sender] += _numTokens;
    self.tokensBought[msg.sender] += _numTokens;

    //subtract tokens from owner's share
    (err,_remainder) = self.base.withdrawTokensMap[self.base.owner].minus(_numTokens);
    require(!err);
    self.base.withdrawTokensMap[self.base.owner] = _remainder;

    LogTokensBought(msg.sender, _numTokens);

    return true;
  }

  /*Functions "inherited" from CrowdsaleLib library*/

  function setTokens(EvenDistroCrowdsaleStorage storage self) public returns (bool) {
    calculateAddressTokenCap(self);
    return self.base.setTokens();
  }

  function withdrawTokens(EvenDistroCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawTokens();
  }

  function withdrawLeftoverWei(EvenDistroCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(EvenDistroCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawOwnerEth();
  }

  function getSaleData(EvenDistroCrowdsaleStorage storage self, uint256 timestamp)
                       public
                       view
                       returns (uint256[3])
  {
    return self.base.getSaleData(timestamp);
  }

  function getTokensSold(EvenDistroCrowdsaleStorage storage self) public view returns (uint256) {
    return self.base.getTokensSold();
  }

  function crowdsaleActive(EvenDistroCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(EvenDistroCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleEnded();
  }
}
