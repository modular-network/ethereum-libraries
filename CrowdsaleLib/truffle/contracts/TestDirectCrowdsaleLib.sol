pragma solidity ^0.4.15;

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

    uint256[] tokenPricePoints;    // price points at each price change interval in cents/token.

  	uint256 changeInterval;      // amount of time between changes in the price of the token
  	uint256 lastPriceChangeTime;          // time of the last change in token cost
    uint256 changeIndex;         //index for the price points array
  }

  event LogTokensBought(address indexed buyer, uint256 amount);
  event LogAddressCapExceeded(address indexed buyer, uint256 amount, string Msg);
  event LogErrorMsg(uint256 amount, string Msg);
  event LogTokenPriceChange(uint256 amount, string Msg);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  function init(DirectCrowdsaleStorage storage self,
                address _owner,
                uint256 _currtime,
                uint256 _capAmountInCents,
                uint256 _startTime,
                uint256 _endTime,
                uint256[] _tokenPricePoints,
                uint256 _fallbackExchangeRate,
                uint256 _changeInterval,
                uint8 _percentBurn,
                CrowdsaleToken _token)
  {
  	self.base.init(_owner,
                _currtime,
                _tokenPricePoints[0],
                _fallbackExchangeRate,
                _capAmountInCents,
                _startTime,
                _endTime,
                _percentBurn,
                _token);

    require(_tokenPricePoints.length > 0);
    if (_tokenPricePoints.length == 1) {             // if there is no increase or decrease in price, the time interval should also be zero
      require(_changeInterval == 0);
    }
  	self.tokenPricePoints = _tokenPricePoints;
    self.changeInterval = _changeInterval;
    self.changeIndex = 1;
    self.lastPriceChangeTime = _startTime;
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
    if ((self.base.ownerBalance + _amount) > self.base.capAmount) {
      LogErrorMsg(msg.value, "buyer ether sent exceeds cap of ether to be raised!");
      return false;
    }

  	// if the token price increase interval has passed, update the current day and change the token price
  	if ((self.changeInterval > 0) && (currtime >= (self.lastPriceChangeTime + self.changeInterval))) {
  		self.lastPriceChangeTime = self.lastPriceChangeTime + self.changeInterval;

      if (self.changeIndex < self.tokenPricePoints.length) {   //prevents going out of bounds on the tokenPricePoints array

  		  self.base.changeTokenPrice(self.tokenPricePoints[self.changeIndex]);

        LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
        self.changeIndex++;
      }
  	}

  	uint256 numTokens;     //number of tokens that will be purchased
  	bool err;
    uint256 newBalance;    //the new balance of the owner of the crowdsale
    uint256 weiTokens;
    uint256 remainder;
    uint256 leftovers;

    (err,weiTokens) = _amount.times(self.base.tokensPerEth);    // Find the number of tokens as a function in wei
    require(!err);

    (err,numTokens) = weiTokens.dividedBy(1000000000000000000);    // convert the wei tokens to the correct number of tokens per ether spent
    require(!err);
    remainder = weiTokens % 1000000000000000000;
    leftovers = remainder / self.base.tokensPerEth;

    self.base.leftoverWei[msg.sender] += leftovers;

    self.base.hasContributed[msg.sender] += _amount - leftovers;      // can't overflow because it is under the cap

    if(self.base.tokenDecimals > 0){
      uint256 _decimals = 10**uint256(self.base.tokenDecimals);
      numTokens = numTokens * _decimals;
    }
    require(numTokens <= self.base.token.balanceOf(this));

    (err,newBalance) = self.base.ownerBalance.plus(_amount-self.base.leftoverWei[msg.sender]);      // calculate the amout of ether in the owners balance
    require(!err);

    self.base.ownerBalance = newBalance;   // "deposit" the amount

	  self.base.withdrawTokensMap[msg.sender] += numTokens;    // can't overflow because it will be under the cap
    (err,remainder) = self.base.withdrawTokensMap[self.base.owner].minus(numTokens);  //subtract tokens from owner's share
    self.base.withdrawTokensMap[self.base.owner] = remainder;

	  LogTokensBought(msg.sender, numTokens);

    return true;
  }

  ///  Functions "inherited" from CrowdsaleLib library
  function setTokenExchangeRate(DirectCrowdsaleStorage storage self, uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    return self.base.setTokenExchangeRate(_exchangeRate, _currtime);
  }

  function crowdsaleActive(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleActive(currtime);
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleEnded(currtime);
  }

  function validPurchase(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.validPurchase(currtime);
  }

  function withdrawTokens(DirectCrowdsaleStorage storage self,uint256 currtime) returns (bool) {
    return self.base.withdrawTokens(currtime);
  }

  function withdrawLeftoverWei(DirectCrowdsaleStorage storage self) returns (bool) {
    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(DirectCrowdsaleStorage storage self,uint256 currtime) returns (bool) {
    return self.base.withdrawOwnerEth(currtime);
  }

  function getContribution(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getContribution(_buyer);
  }

  function getTokenPurchase(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getTokenPurchase(_buyer);
  }

  function getLeftoverWei(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    return self.base.getLeftoverWei(_buyer);
  }

}
