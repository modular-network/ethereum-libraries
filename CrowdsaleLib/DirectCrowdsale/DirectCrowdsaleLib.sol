pragma solidity ^0.4.18;

/**
 * @title DirectCrowdsaleLib
 * @author Modular Inc, https://modular.network
 *
 * version 2.2.1
 * Copyright (c) 2017 Modular Inc
 * The MIT License (MIT)
 * https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE
 *
 * The DirectCrowdsale Library provides functionality to create a initial coin offering
 * for a standard token sale with high supply where there is a direct ether to
 * token transfer.
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

library DirectCrowdsaleLib {
  using BasicMathLib for uint256;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  struct DirectCrowdsaleStorage {

  	CrowdsaleLib.CrowdsaleStorage base; // base storage from CrowdsaleLib

  }

  event LogTokensBought(address indexed buyer, uint256 amount);
  event LogTokenPriceChange(uint256 amount, string Msg);
  event LogErrorMsg(uint256 amount, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in tokens/ETH at that time,
  /// 3 is address purchase cap at that time, 0 if no address cap
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _token Token being sold
  function init(DirectCrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _endTime,
                uint8 _percentBurn,
                CrowdsaleToken _token)
                public
  {
  	self.base.init(_owner,
                _saleData,
                _endTime,
                _percentBurn,
                _token);
  }

  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amount of wei that the buyer is sending
  /// @return true on succesful purchase
  function receivePurchase(DirectCrowdsaleStorage storage self, uint256 _amount)
                           public
                           returns (bool)
  {
    require(msg.sender != self.base.owner);
  	require(self.base.validPurchase());

  	// if the token price increase interval has passed, update the current day and change the token price
  	if ((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
        (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
    {
        while((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
              (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
        {
          self.base.currentMilestone += 1;
        }

        self.base.changeTokenPrice(self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][0]);
        LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
    }

  	uint256 _numTokens; //number of tokens that will be purchased
    uint256 _newBalance; //the new balance of the owner of the crowdsale
    uint256 _weiTokens; //temp calc holder
    uint256 _leftoverWei; //wei change for purchaser
    uint256 _remainder; //temp calc holder
    bool err;

    // Find the number of tokens as a function in wei
    (err,_weiTokens) = _amount.times(self.base.tokensPerEth);
    require(!err);

    _numTokens = _weiTokens / 1000000000000000000;
    _remainder = _weiTokens % 1000000000000000000;
    _remainder = _remainder / self.base.tokensPerEth;
    _leftoverWei += _remainder;
    _amount = _amount - _remainder;
    self.base.leftoverWei[msg.sender] += _leftoverWei;

    // can't overflow because it is under the cap
    self.base.hasContributed[msg.sender] += _amount;

    assert(_numTokens <= self.base.token.balanceOf(this));

    // calculate the amount of ether in the owners balance
    (err,_newBalance) = self.base.ownerBalance.plus(_amount);
    require(!err);

    self.base.ownerBalance = _newBalance;   // "deposit" the amount

    // can't overflow because it will be under the cap
	  self.base.withdrawTokensMap[msg.sender] += _numTokens;

    //subtract tokens from owner's share
    (err,_remainder) = self.base.withdrawTokensMap[self.base.owner].minus(_numTokens);
    require(!err);
    self.base.withdrawTokensMap[self.base.owner] = _remainder;

	  LogTokensBought(msg.sender, _numTokens);

    return true;
  }

  /*Functions "inherited" from CrowdsaleLib library*/

  function setTokens(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.setTokens();
  }

  function withdrawTokens(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawTokens();
  }

  function withdrawLeftoverWei(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawOwnerEth();
  }

  function getSaleData(DirectCrowdsaleStorage storage self, uint256 timestamp)
                       public
                       view
                       returns (uint256[3])
  {
    return self.base.getSaleData(timestamp);
  }

  function getTokensSold(DirectCrowdsaleStorage storage self) public view returns (uint256) {
    return self.base.getTokensSold();
  }

  function crowdsaleActive(DirectCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleEnded();
  }
}
