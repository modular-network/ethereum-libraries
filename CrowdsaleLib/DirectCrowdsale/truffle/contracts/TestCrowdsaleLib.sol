pragma solidity ^0.4.15;

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
    uint256 startTime; //ICO start time, timestamp
    uint256 endTime; //ICO end time, timestamp automatically calculated
    uint256 exchangeRate;   //  cents/ETH exchange rate at the time of the sale
    uint256 ownerBalance; //owner wei Balance
    uint256 startingTokenBalance; //initial amount of tokens for sale
    uint256[] milestoneTimes; //Array of timestamps when token price and address cap changes
    uint8 currentMilestone; //Pointer to the current milestone
    uint8 tokenDecimals;
    uint8 percentBurn;
    bool tokensSet;
    bool rateSet;

    mapping (uint256 => uint256[2]) saleData;
  	mapping (address => uint256) hasContributed;  //shows how much wei an address has contributed
  	mapping (address => uint256) withdrawTokensMap;  //For token withdraw function, maps a user address to the amount of tokens they can withdraw
    mapping (address => uint256) leftoverWei;       // any leftover wei that buyers contributed that didn't add up to a whole token amount

  	CrowdsaleToken token;
  }

  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);      // Indicates when an address has withdrawn their supply of tokens
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);      // Indicates when an address has withdrawn their supply of extra wei
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);          // Generic Notice message that includes and address and number
  event LogErrorMsg(string Msg);                                          // Indicates when an error has occurred in the execution of a function

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  function init(CrowdsaleStorage storage self,
                address _owner,
                uint256 _currtime,
                uint256[] _saleData,
                uint256 _fallbackExchangeRate,
                uint256 _capAmountInCents,
                uint256 _endTime,
                uint8 _percentBurn,
                CrowdsaleToken _token)
  {
  	require(self.capAmount == 0);
  	require(self.owner == 0);
    require(_saleData.length > 0);
    require((_saleData.length%3) == 0);
    require(_saleData[0] > (_currtime + 3));
    require(_endTime > _saleData[0]);
    require(_capAmountInCents > 0);
    require(_owner > 0);
    require(_fallbackExchangeRate > 0);
    require(_percentBurn <= 100);
    self.owner = _owner;
    self.capAmount = ((_capAmountInCents/_fallbackExchangeRate) + 1)*(10**18);
    self.startTime = _saleData[0];
    self.endTime = _endTime;
    self.token = _token;
    self.tokenDecimals = _token.decimals();
    self.percentBurn = _percentBurn;
    self.exchangeRate = _fallbackExchangeRate;

    uint256 _tempTime;
    for(uint256 i = 0; i < _saleData.length; i += 3){
      require(_saleData[i] > _tempTime);
      require(_saleData[i + 1] > 0);
      require((_saleData[i + 2] == 0) || (_saleData[i + 2] >= 100));
      self.milestoneTimes.push(_saleData[i]);
      self.saleData[_saleData[i]][0] = _saleData[i + 1];
      self.saleData[_saleData[i]][1] = _saleData[i + 2];
      _tempTime = _saleData[i];
    }
    changeTokenPrice(self, _saleData[1]);
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
  function validPurchase(CrowdsaleStorage storage self, uint256 currtime) internal constant returns (bool) {
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
  function withdrawTokens(CrowdsaleStorage storage self,uint256 currtime) returns (bool) {
    bool ok;

    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg("Sender has no tokens to withdraw!");
      return false;
    }
    if (msg.sender == self.owner) {
      if (!crowdsaleEnded(self,currtime)){
        LogErrorMsg("Owner cannot withdraw extra tokens until after the sale!");
        return false;
      } else {
        if(self.percentBurn > 0){
          uint256 _burnAmount = (self.withdrawTokensMap[msg.sender] * self.percentBurn)/100;
          self.withdrawTokensMap[msg.sender] = self.withdrawTokensMap[msg.sender] - _burnAmount;
          ok = self.token.burnToken(_burnAmount);
          require(ok);
        }
      }
    }

    var total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    ok = self.token.transfer(msg.sender, total);
    require(ok);
    LogTokensWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev Function called by purchasers to pull leftover wei from their purchases
  /// @param self Stored crowdsale from crowdsale contract
  function withdrawLeftoverWei(CrowdsaleStorage storage self) returns (bool) {
    if (self.leftoverWei[msg.sender] == 0) {
      LogErrorMsg("Sender has no extra wei to withdraw!");
      return false;
    }
    require(self.hasContributed[msg.sender] > 0);

    var total = self.leftoverWei[msg.sender];
    self.leftoverWei[msg.sender] = 0;
    msg.sender.transfer(total);
    LogWeiWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev send ether from a purchase to the owners wallet address
  function withdrawOwnerEth(CrowdsaleStorage storage self, uint256 currtime) internal returns (bool) {
    if (!crowdsaleEnded(self, currtime)) {
      LogErrorMsg("Cannot withdraw owner ether until after the sale");
      return false;
    }

    require(msg.sender == self.owner);
    require(self.ownerBalance > 0);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.owner.transfer(amount);
    LogOwnerEthWithdrawn(msg.sender,amount,"crowdsale owner has withdrawn all funds");

    return true;
  }

  /// @dev Function to change the price of the token
  /// @param _newPrice new token price (amount of tokens per ether)
  function changeTokenPrice(CrowdsaleStorage storage self,uint256 _newPrice) internal returns (bool) {
    require(_newPrice > 0);

    uint256 result;
    bool err;

    (err,result) = self.exchangeRate.dividedBy(_newPrice);
    require(!err);

    self.tokensPerEth = result + 1;
    return true;
  }

  /// @dev function that is called two days before the sale to set the token price
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param _exchangeRate  ETH exchange rate expressed in cents/ETH
  function setTokenExchangeRate(CrowdsaleStorage storage self, uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    if (msg.sender != self.owner) {
      LogErrorMsg("Owner can only set the exchange rate!");
      return false;
    }
    if ((_currtime >= (self.startTime - 3)) && (_currtime <= (self.startTime)) && (self.rateSet == false)) {
      require(self.rateSet == false);
    } else {
      LogErrorMsg("Owner can only set the exchange rate once up to three days before the sale!");
      return false;
    }
    if (self.token.balanceOf(this) == 0) {
      LogErrorMsg("Crowdsale contract should have tokens in balance before sale starts");
      return false;
    }
    if (_exchangeRate == 0) {
      LogErrorMsg("Exchange rate must be greater than zero!");
      return false;
    }
    uint256 _capAmountInCents;
    uint256 _tokenPriceInCents;
    bool err;

    (err, _capAmountInCents) = self.exchangeRate.times(self.capAmount);
    require(!err);

    (err, _tokenPriceInCents) = self.exchangeRate.dividedBy(self.tokensPerEth);
    require(!err);

    self.withdrawTokensMap[msg.sender] = self.token.balanceOf(this);
    self.tokensSet = true;

    self.exchangeRate = _exchangeRate;
    self.capAmount = (_capAmountInCents/_exchangeRate) + 1;
    changeTokenPrice(self,_tokenPriceInCents + 1);
    self.rateSet = true;

    LogNoticeMsg(msg.sender,self.tokensPerEth,"Owner has sent the exchange Rate and tokens bought per ETH!");
    return true;
  }

  function setTokens(CrowdsaleStorage storage self) returns (bool) {
    require(msg.sender == self.owner);
    require(!self.tokensSet);

    self.withdrawTokensMap[msg.sender] = self.token.balanceOf(this);
    self.tokensSet = true;

    return true;
  }

  /// @dev Gets the price and buy cap for individual addresses at the given milestone index
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param timestamp Time during sale for which data is requested
  /// @return A 3-element array with 0 the timestamp, 1 the price in cents, 2 the address cap
  function getSaleData(CrowdsaleStorage storage self, uint256 timestamp) constant returns (uint256[3]) {
    uint256[3] memory _thisData;
    uint256 index = 0;
    for(uint256 i = 0; i<self.milestoneTimes.length; i++){
      if (self.milestoneTimes[i] < timestamp) {
        index++;
      } else {
        break;
      }
    }
    _thisData[0] = self.milestoneTimes[index - 1];
    _thisData[1] = self.saleData[_thisData[0]][0];
    _thisData[2] = self.saleData[_thisData[0]][1];
    return _thisData;
  }

  /// @dev Gets the number of tokens sold thus far
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return Number of tokens sold
  function getTokensSold(CrowdsaleStorage storage self) constant returns (uint256) {
    return self.startingTokenBalance - self.token.balanceOf(this);
  }
}
