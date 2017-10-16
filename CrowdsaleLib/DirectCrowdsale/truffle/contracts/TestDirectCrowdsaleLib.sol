pragma solidity ^0.4.15;

/**
 * @title DirectCrowdsaleLib
 * @author Majoolr.io
 *
 * version 2.0.0
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
                uint256[] _saleData,
                uint256 _fallbackExchangeRate,
                uint256 _capAmountInCents,
                uint256 _endTime,
                uint8 _percentBurn,
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
    if ((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
        (currtime > self.base.milestoneTimes[self.base.currentMilestone + 1]))
    {
        while((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
              (currtime > self.base.milestoneTimes[self.base.currentMilestone + 1]))
        {
          self.base.currentMilestone += 1;
        }

        self.base.changeTokenPrice(self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][0]);
        LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
    }

  	uint256 _numTokens;     //number of tokens that will be purchased
    uint256 _newBalance;    //the new balance of the owner of the crowdsale
    uint256 _weiTokens;
    uint256 _zeros;
    uint256 _leftoverWei;
    uint256 _remainder;
    bool err;

    (err,_weiTokens) = _amount.times(self.base.tokensPerEth);    // Find the number of tokens as a function in wei
    require(!err);

    if(self.base.tokenDecimals <= 18){
      _zeros = 10**(18-uint256(self.base.tokenDecimals));
      _numTokens = _weiTokens/_zeros;
      _leftoverWei = _weiTokens % _zeros;
      self.base.leftoverWei[msg.sender] += _leftoverWei;
    } else {
      _zeros = 10**(uint256(self.base.tokenDecimals)-18);
      _numTokens = _weiTokens*_zeros;
    }

    self.base.hasContributed[msg.sender] += _amount - _leftoverWei;      // can't overflow because it is under the cap

    require(_numTokens <= self.base.token.balanceOf(this));

    (err,_newBalance) = self.base.ownerBalance.plus(_amount-_leftoverWei);      // calculate the amout of ether in the owners balance
    require(!err);

    self.base.ownerBalance = _newBalance;   // "deposit" the amount

	  self.base.withdrawTokensMap[msg.sender] += _numTokens;    // can't overflow because it will be under the cap
    (err,_remainder) = self.base.withdrawTokensMap[self.base.owner].minus(_numTokens);  //subtract tokens from owner's share
    self.base.withdrawTokensMap[self.base.owner] = _remainder;

	  LogTokensBought(msg.sender, _numTokens);

    return true;
  }

  ///  Functions "inherited" from CrowdsaleLib library
  function setTokenExchangeRate(DirectCrowdsaleStorage storage self, uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    return self.base.setTokenExchangeRate(_exchangeRate, _currtime);
  }

  function setTokens(DirectCrowdsaleStorage storage self) returns (bool) {
    return self.base.setTokens();
  }

  function getSaleData(DirectCrowdsaleStorage storage self, uint256 timestamp) returns (uint256[3]) {
    return self.base.getSaleData(timestamp);
  }

  function getTokensSold(DirectCrowdsaleStorage storage self) constant returns (uint256) {
    return self.base.getTokensSold();
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

  function crowdsaleActive(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleActive(currtime);
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.crowdsaleEnded(currtime);
  }

  function validPurchase(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    return self.base.validPurchase(currtime);
  }
}
