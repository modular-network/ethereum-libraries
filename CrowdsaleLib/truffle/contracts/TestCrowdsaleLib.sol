pragma solidity ^0.4.13;

/**
 * @title CrowdsaleLib
 * @author Majoolr.io
 *
 * version 1.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Crowdsale Library provides basic functionality to create a initial coin offering
 * for different types of token sales. 
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
import "./CrowdsaleToken.sol";

library TestCrowdsaleLib {
  using BasicMathLib for uint256;

  struct CrowdsaleStorage {
  	address owner;     //owner of the crowdsale

  	uint256 tokensPerEth;  //number of tokens received per ether
  	uint256 capAmount; //Maximum amount to be raised in wei
  	//uint8 decimals; //Number of zeros to add to token supply, usually 18
  	uint256 startTime; //ICO start time, timestamp
  	uint256 endTime; //ICO end time, timestamp automatically calculated


  	mapping (address => uint256) hasContributed;  //shows how much wei an address has contributed
  	mapping (address => uint) withdrawTokensMap;  //For token withdraw function, maps a user address to the amount of tokens they can withdraw

  	CrowdsaleToken token;
  }

  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
  event LogDepositWithdrawn(address indexed _bidder, uint256 Amount);
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);
  event LogErrorMsg(string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  function init(CrowdsaleStorage storage self, 
                address _owner,
                uint256 _currtime,
                uint256 _tokensPerEth,
                uint256 _capAmount,
                uint256 _startTime,
                uint256 _endTime,
                CrowdsaleToken _token)
  {
  	require(self.capAmount == 0);
  	require(self.owner == 0);
  	require(_startTime >= _currtime);
    require(_endTime > _startTime);
    require(_tokensPerEth > 0);
    require(_capAmount > 0);
    require(_owner > 0);
    require(_startTime > _currtime);
    self.owner = _owner;
    self.tokensPerEth = _tokensPerEth;
    self.capAmount = _capAmount;
    self.startTime = _startTime;
    self.endTime = _endTime;
    self.token = _token;
  }  

  /// @dev function to check if the crowdsale is currently active
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleActive(CrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
  	return (currtime >= self.startTime && currtime <= self.endTime);
  }

  /// @dev function to check if the crowdsale has ended
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleEnded(CrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
  	return currtime > self.endTime;
  }

  /// @dev function to check if a purchase is valid
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if the transaction can buy tokens
  function validPurchase(CrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    if (crowdsaleActive(self,currtime) && nonZeroPurchase) {
      return true;
    } else {
      LogErrorMsg("Invalid Purchase! Check send time and amount of ether.");
      return false;
    }
  }

  /// @dev Function called by purchasers to pull tokens
  /// @param self Stored crowdsale from crowdsale contract
  function withdrawTokens(CrowdsaleStorage storage self) returns (bool) {
    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg("Sender has no tokens to withdraw!");
      return false;
    }

    var total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    bool ok = self.token.transferFrom(self.owner, msg.sender, total);
    require(ok);
    LogTokensWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev Function to change the price of the token
  /// @param _newPrice new token price (amount of tokens per ether)
  function changeTokenPrice(CrowdsaleStorage storage self,uint256 _newPrice) internal returns (bool) {

    //require(msg.sender == self.owner);
  	require(_newPrice > 0);

  	self.tokensPerEth = _newPrice;
    return true;
  }

  /// @dev Gets the amount of ether that an account has contributed
  /// @param _buyer address to get the information for
  /// @return amount of ether 
  function getContribution(CrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    LogNoticeMsg(_buyer, self.hasContributed[_buyer], "Users ether contribution");
    return self.hasContributed[_buyer];
  }

  /// @dev returns the number of tokens that an account has purchased
  /// @param _buyer address to get the information for
  /// @return number of tokens the account can withdraw 
  function getTokenPurchase(CrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
    LogNoticeMsg(_buyer, self.withdrawTokensMap[_buyer], "Users token purchase");
    return self.withdrawTokensMap[_buyer];
  }

}





















