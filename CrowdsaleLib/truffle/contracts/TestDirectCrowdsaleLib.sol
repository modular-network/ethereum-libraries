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

library TestDirectCrowdsaleLib {
  using BasicMathLib for uint256;
  using TestCrowdsaleLib for TestCrowdsaleLib.CrowdsaleStorage;

  struct DirectCrowdsaleStorage {

  	TestCrowdsaleLib.CrowdsaleStorage base;

    uint256 minimumTargetRaise; //Minimum amount acceptable for successful auction in wei

  	uint256 periodicChange;    // amount in ether that the token price changes after a specified interval
  	uint256 changeInterval;      // amount of time between changes in the price of the token
  	uint256 lastPriceChangeTime;          // time of the last change in token cost
    uint256 ownerBalance;

  	bool increase;             // true if the price of the token increases, false if it decreases
  }

  event LogTokensBought(address indexed buyer, uint256 amount);
  event LogAddressCapExceeded(address indexed buyer, uint256 amount, string Msg);
  event LogOwnerWithdrawl(address indexed owner, uint256 amount, string Msg);
  event LogErrorMsg(uint256 amount, string Msg);
  event LogTokenPriceChange(uint256 amount, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  function init(DirectCrowdsaleStorage storage self,
                address _owner,
                uint256 _currtime,
                uint256 _tokensPerEth,
                uint256 _capAmount,
                uint256 _minimumTargetRaise,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _periodicChange,
                uint256 _changeInterval,
                bool _increase,
                CrowdsaleToken _token)
  {
  	self.base.init(_owner,
                _currtime,
                _tokensPerEth,
                _capAmount,
                _startTime,
                _endTime,
                _token);

    if (_periodicChange == 0) {             // if there is no increase or decrease in price, the time interval should also be zero
    	require(_changeInterval == 0);
    }
    self.minimumTargetRaise = _minimumTargetRaise;
  	self.periodicChange = _periodicChange;
  	self.changeInterval = _changeInterval; 
  	self.increase = _increase;
  	self.lastPriceChangeTime = _startTime;
    self.ownerBalance = 0;
  }

  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  function receivePurchase(DirectCrowdsaleStorage storage self, uint256 _amount, uint256 currtime) returns (bool) {
    if(msg.sender == self.base.owner) {
      LogErrorMsg(msg.value, "Owner cannot send ether to contract");
      return false;
    }        //NEEDS a REQUIRE
    if (!self.base.validPurchase(currtime)) {   //NEEDS TO BE A REQUIRE
      return false;
    }
    if ((self.ownerBalance + _amount) > self.base.capAmount) {
      LogErrorMsg(msg.value, "buyer ether sent exceeds cap of ether to be raised!");
      return false;
    }

  	// if the token price increase interval has passed, update the current day and change the token price
  	if ((self.changeInterval > 0) && (currtime >= (self.lastPriceChangeTime + self.changeInterval))) {
  		self.lastPriceChangeTime = currtime;
  		if (self.increase) { 
        self.base.changeTokenPrice(self.base.tokensPerEth + self.periodicChange);
        LogTokenPriceChange(self.periodicChange,"Token Price has increased!"); 
      } else { 
        self.base.changeTokenPrice(self.base.tokensPerEth - self.periodicChange); 
        LogTokenPriceChange(self.periodicChange,"Token Price has decreased!");
      }   
  	}

  	uint256 numTokens;     //number of tokens that will be purchased
  	bool err;
    uint256 newBalance;    //the new balance of the owner of the crowdsale
    uint256 weiTokens;

    self.base.hasContributed[msg.sender] += _amount;      // can't overflow because it is under the cap
    
    (err,weiTokens) = _amount.times(self.base.tokensPerEth);

    require(!err);

    (err,numTokens) = weiTokens.dividedBy(1000000000000000000);

    require(!err);

    (err,newBalance) = self.ownerBalance.plus(_amount);

    require(!err);

    self.ownerBalance = newBalance;
	  
	  self.base.withdrawTokensMap[msg.sender] += numTokens;    // can't overflow because it will be under the cap

	  LogTokensBought(msg.sender, numTokens);

    return true;
  }

  /// @dev send ether from a purchase to the owners wallet address
  function ownerWithdrawl(DirectCrowdsaleStorage storage self, uint256 currtime) internal returns (bool) {
    if (!self.base.crowdsaleEnded(currtime)) {
      LogErrorMsg(self.ownerBalance, "Cannot withdraw owner ether until after the sale");
      return false;
    }
    //require(self.base.crowdsaleEnded(currtime));
    require(msg.sender == self.base.owner);    
    require(self.ownerBalance > 0);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.base.owner.transfer(amount);
    LogOwnerWithdrawl(msg.sender,amount,"crowdsale owner has withdrawn all funds");

    return true;
  }
 

  ///  Functions "inherited" from CrowdsaleLib library


  function crowdsaleActive(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleActive(currtime);
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleEnded(currtime);
  }

  function validPurchase(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.validPurchase(currtime);
  }

  function withdrawTokens(DirectCrowdsaleStorage storage self) returns (bool) {
    return self.base.withdrawTokens();
  }

  function changeTokenPrice(DirectCrowdsaleStorage storage self, uint256 _newPrice) returns (bool) {
    return self.base.changeTokenPrice(_newPrice);
  }

  function getContribution(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getContribution(_buyer);
  }

  function getTokenPurchase(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getTokenPurchase(_buyer);
  }


}
