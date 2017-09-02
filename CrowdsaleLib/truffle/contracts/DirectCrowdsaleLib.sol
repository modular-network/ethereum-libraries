pragma solidity ^0.4.13;

/**
 * @title DirectCrowdsaleLib
 * @author Majoolr.io
 *
 * version 1.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The DirectCrowdsale Library provides functionality to create a initial coin offering
 * for a standard token sale with high supply where there is a direct ether to
 * token transfer.  
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
import "./CrowdsaleLib.sol";

library DirectCrowdsaleLib {
  using BasicMathLib for uint256;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  struct DirectCrowdsaleStorage {

  	CrowdsaleLib.CrowdsaleStorage base;

  	uint256 periodicChange;    // amount in ether that the token price changes after a specified interval
  	uint256 timeInterval;      // amount of time between changes in the price of the token
  	uint256 weiRaised;      // amount of wei raised in the token sale
  	uint256 currDay;          // current Day

  	bool increase;             // true if the price of the token increases, false if it decreases

  }

  event TokensBought(address indexed buyer, uint256 amount);

  // event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
  // event LogDepositWithdrawn(address indexed _bidder, uint256 Amount);
  // event LogNoticeMsg(address indexed _from, string Msg);
  // event LogErrorMsg(address indexed _from, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _decimals Decimal places for the token represented
  function init(DirectCrowdsaleStorage storage self,
                address _owner,
                uint256 _tokenPrice,
                uint256 _capAmount,
                uint256 _minimumTargetRaise,
                uint256 _auctionSupply,
                uint8 _decimals,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _addressCap,
                uint256 _periodicChange,
                uint256 _timeInterval,
                bool _increase,
                CrowdsaleToken _token)
  {
  	self.base.init(_owner,
                _tokenPrice,
                _capAmount,
                _minimumTargetRaise,
                _auctionSupply,
                _decimals,
                _startTime,
                _endTime,
                _addressCap,
                _token);

    if (_periodicChange == 0) {             // if there is no increase or decrease in price, the time interval should also be zero
    	require(_timeInterval == 0);
    }
  	self.periodicChange = _periodicChange;
  	self.timeInterval = _timeInterval; 
  	self.increase = _increase;
  	self.weiRaised = 0;
  	self.currDay = _startTime;
  }

  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  function receivePurchase(DirectCrowdsaleStorage storage self, uint256 _amount) {
  	require(self.base.validPurchase());
  	require(self.base.hasContributed[msg.sender] < self.base.addressCap);
  	require(self.weiRaised < self.base.capAmount);

  	// if the token price increase interval has passed, update the current day and change the token price
  	if ((self.timeInterval > 0) && (now > (self.currDay + self.timeInterval))) {
  		self.currDay = now;
  		if (self.increase) { self.base.increaseTokenPrice(self.periodicChange); }
  		else { self.base.decreaseTokenPrice(self.periodicChange); }
  	}

  	uint256 numTokens;     //number of tokens that will be purchased
  	bool err;

  	// if the sender over pays their allocated contribution, put the leftover ether into a mapping for their address that they can withdraw later
  	if (self.base.hasContributed[msg.sender] + _amount > self.base.addressCap) {
		  uint256 leftoverWei = _amount - (self.base.addressCap-self.base.hasContributed[msg.sender]);
		  uint256 amountContributed = _amount-leftoverWei;
		  self.base.hasContributed[msg.sender] += amountContributed;     // can't overflow because it will be under the cap
		  self.base.excessEther[msg.sender] += leftoverWei;				// can this overflow?
		  (err,numTokens) = amountContributed.dividedBy(self.base.tokenPrice);

		  require(!err);

	  } else {
		  self.base.hasContributed[msg.sender] += _amount;      // can't overflow because it is under the cap
		  (err,numTokens) = _amount.dividedBy(self.base.tokenPrice);

		  require(!err);
	  }

	  self.base.withdrawTokensMap[msg.sender] += numTokens;    // can't overflow because it will be under the cap

    forwardEthertoOwner(self.base.owner);

	  TokensBought(msg.sender, numTokens);

  }

  /// @dev send ether from a purchase to the owners wallet address
  function forwardEthertoOwner(address _owner) internal {
    _owner.transfer(msg.value);
  }
 

  ///  Functions "inherited" from CrowdsaleLib library


  function crowdsaleActive(DirectCrowdsaleStorage storage self) constant returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self) constant returns (bool) {
    return self.base.crowdsaleEnded();
  }

  function validPurchase(DirectCrowdsaleStorage storage self) constant returns (bool) {
    return self.base.validPurchase();
  }

  function withdrawTokens(DirectCrowdsaleStorage storage self) {
    self.base.withdrawTokens();
  }

  function withdrawEther(DirectCrowdsaleStorage storage self) {
    self.base.withdrawEther();
  }

  function increaseTokenPrice(DirectCrowdsaleStorage storage self, uint256 _amount) {
    self.base.increaseTokenPrice(_amount);
  }

  function decreaseTokenPrice(DirectCrowdsaleStorage storage self, uint256 _amount) {
    self.base.decreaseTokenPrice(_amount);
  }

  function changeAddressCap(DirectCrowdsaleStorage storage self, uint256 _newCap) returns (bool) {
    return self.base.changeAddressCap(_newCap);
  }

  function getContribution(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getContribution(_buyer);
  }

  function getTokenPurchase(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getTokenPurchase(_buyer);
  }

  function getExcessEther(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getExcessEther(_buyer);
  }



}
