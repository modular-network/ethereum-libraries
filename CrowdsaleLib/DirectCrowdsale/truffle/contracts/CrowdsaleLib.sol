pragma solidity ^0.4.15;

/**
 * @title CrowdsaleLib
 * @author Majoolr.io
 *
 * version 2.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Crowdsale Library provides basic functionality to create an initial coin
 * offering for different types of token sales.
 *
 * Majoolr provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology. For further information: majoolr.io
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

library CrowdsaleLib {
  using BasicMathLib for uint256;

  struct CrowdsaleStorage {
  	address owner;     //owner of the crowdsale

  	uint256 tokensPerEth;  //number of tokens received per ether
  	uint256 capAmount; //Maximum amount to be raised in wei
  	uint256 startTime; //ICO start time, timestamp
  	uint256 endTime; //ICO end time, timestamp automatically calculated
    uint256 exchangeRate; //cents/ETH exchange rate at the time of the sale
    uint256 ownerBalance; //owner wei Balance
    uint256 startingTokenBalance; //initial amount of tokens for sale
    uint256[] milestoneTimes; //Array of timestamps when token price and address cap changes
    uint8 currentMilestone; //Pointer to the current milestone
    uint8 tokenDecimals; //stored token decimals for calculation later
    uint8 percentBurn; //percentage of extra tokens to burn
    bool tokensSet; //true if tokens have been prepared for crowdsale
    bool rateSet; //true if exchange rate has been set

    //Maps timestamp to token price and address purchase cap starting at that time
    mapping (uint256 => uint256[2]) saleData;

    //shows how much wei an address has contributed
  	mapping (address => uint256) hasContributed;

    //For token withdraw function, maps a user address to the amount of tokens they can withdraw
  	mapping (address => uint256) withdrawTokensMap;

    // any leftover wei that buyers contributed that didn't add up to a whole token amount
    mapping (address => uint256) leftoverWei;

  	CrowdsaleToken token; //token being sold
  }

  // Indicates when an address has withdrawn their supply of tokens
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);

  // Indicates when an address has withdrawn their supply of extra wei
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);

  // Logs when owner has pulled eth
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);

  // Generic Notice message that includes and address and number
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);

  // Indicates when an error has occurred in the execution of a function
  event LogErrorMsg(string Msg);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in cents at that time,
  /// 3 is address token purchase cap at that time, 0 if no address cap
  /// @param _fallbackExchangeRate Exchange rate of cents/ETH
  /// @param _capAmountInCents Total to be raised in cents
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _token Token being sold
  function init(CrowdsaleStorage storage self,
                address _owner,
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
    require((_saleData.length%3) == 0); // ensure saleData is 3-item sets
    require(_saleData[0] > (now + 3 days));
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
  function crowdsaleActive(CrowdsaleStorage storage self) constant returns (bool) {
  	return (now >= self.startTime && now <= self.endTime);
  }

  /// @dev function to check if the crowdsale has ended
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleEnded(CrowdsaleStorage storage self) constant returns (bool) {
  	return now > self.endTime;
  }

  /// @dev function to check if a purchase is valid
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if the transaction can buy tokens
  function validPurchase(CrowdsaleStorage storage self) internal constant returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    if (crowdsaleActive(self) && nonZeroPurchase) {
      return true;
    } else {
      LogErrorMsg("Invalid Purchase! Check send time and amount of ether.");
      return false;
    }
  }

  /// @dev Function called by purchasers to pull tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if tokens were withdrawn
  function withdrawTokens(CrowdsaleStorage storage self) returns (bool) {
    bool ok;

    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg("Sender has no tokens to withdraw!");
      return false;
    }

    if (msg.sender == self.owner) {
      if(!crowdsaleEnded(self)){
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
  /// @return true if wei was withdrawn
  function withdrawLeftoverWei(CrowdsaleStorage storage self) returns (bool) {
    require(self.hasContributed[msg.sender] > 0);
    if (self.leftoverWei[msg.sender] == 0) {
      LogErrorMsg("Sender has no extra wei to withdraw!");
      return false;
    }

    var total = self.leftoverWei[msg.sender];
    self.leftoverWei[msg.sender] = 0;
    msg.sender.transfer(total);
    LogWeiWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev send ether from the completed crowdsale to the owners wallet address
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if owner withdrew eth
  function withdrawOwnerEth(CrowdsaleStorage storage self) returns (bool) {
    if ((!crowdsaleEnded(self)) && (self.token.balanceOf(this)>0)) {
      LogErrorMsg("Cannot withdraw owner ether until after the sale!");
      return false;
    }

    require(msg.sender == self.owner);
    require(self.ownerBalance > 0);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.owner.transfer(amount);
    LogOwnerEthWithdrawn(msg.sender,amount,"Crowdsale owner has withdrawn all funds!");

    return true;
  }

  /// @dev Function to change the price of the token
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _newPrice new token price (amount of tokens per ether)
  /// @return true if the token price changed successfully
  function changeTokenPrice(CrowdsaleStorage storage self,uint256 _newPrice) internal returns (bool) {
  	require(_newPrice > 0);

    uint256 result;
    uint256 remainder;

    result = self.exchangeRate / _newPrice;
    remainder = self.exchangeRate % _newPrice;
    if(remainder > 0) {
      self.tokensPerEth = result + 1;
    } else {
      self.tokensPerEth = result;
    }
    return true;
  }

  /// @dev function that is called three days before the sale to set the token and price
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param _exchangeRate  ETH exchange rate expressed in cents/ETH
  /// @return true if the exchange rate has been set
  function setTokenExchangeRate(CrowdsaleStorage storage self, uint256 _exchangeRate) returns (bool) {
    require(msg.sender == self.owner);
    require((now > (self.startTime - 3 days)) && (now < (self.startTime)));
    require(!self.rateSet);   // the exchange rate can only be set once!
    require(self.token.balanceOf(this) > 0);
    require(_exchangeRate > 0);

    uint256 _capAmountInCents;
    uint256 _tokenBalance;
    bool err;

    (err, _capAmountInCents) = self.exchangeRate.times(self.capAmount);
    require(!err);

    _tokenBalance = self.token.balanceOf(this);
    self.withdrawTokensMap[msg.sender] = _tokenBalance;
    self.startingTokenBalance = _tokenBalance;
    self.tokensSet = true;

    self.exchangeRate = _exchangeRate;
    self.capAmount = (_capAmountInCents/_exchangeRate) + 1;
    changeTokenPrice(self,self.saleData[self.milestoneTimes[0]][0]);
    self.rateSet = true;

    LogNoticeMsg(msg.sender,self.tokensPerEth,"Owner has sent the exchange Rate and tokens bought per ETH!");
    return true;
  }

  /// @dev fallback function to set tokens if the exchange rate function was not called
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return true if tokens set successfully
  function setTokens(CrowdsaleStorage storage self) returns (bool) {
    require(msg.sender == self.owner);
    require(!self.tokensSet);

    uint256 _tokenBalance;

    _tokenBalance = self.token.balanceOf(this);
    self.withdrawTokensMap[msg.sender] = _tokenBalance;
    self.startingTokenBalance = _tokenBalance;
    self.tokensSet = true;

    return true;
  }

  /// @dev Gets the price and buy cap for individual addresses at the given milestone index
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param timestamp Time during sale for which data is requested
  /// @return A 3-element array with 0 the timestamp, 1 the price in cents, 2 the address cap
  function getSaleData(CrowdsaleStorage storage self, uint256 timestamp) constant returns (uint256[3]) {
    uint256[3] memory _thisData;
    uint256 index;

    while((index < self.milestoneTimes.length) && (self.milestoneTimes[index] < timestamp)) {
      index++;
    }
    if(index == 0)
      index++;

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
