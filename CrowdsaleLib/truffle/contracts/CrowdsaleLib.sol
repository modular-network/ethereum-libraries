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
import "./Array256Lib.sol";
import "./CrowdsaleToken.sol";

library CrowdsaleLib {
  using BasicMathLib for uint256;
  using Array256Lib for uint256[];

  struct CrowdsaleStorage {
  	address owner;     //owner of the crowdsale

  	uint256 tokenPrice;  //price (in wei) of each token
  	uint256 capAmount; //Maximum amount to be raised in ether
  	uint256 minimumTargetRaise; //Minimum amount acceptable for successful auction in ether
  	uint256 auctionSupply; // number of tokens available in the sale
  	uint8 decimals; //Number of zeros to add to token supply, usually 18
  	uint256 startTime; //ICO start time, timestamp
  	uint256 endTime; //ICO end time, timestamp automatically calculated
  	uint256 addressCap;      //amount of ether one account can spend in the sale

  	mapping (address => bool) isRegistered;       //indicates if an address has registered for the crowdsale
  	mapping (address => uint256) hasContributed;  //shows how much ether an address has contributed
  	mapping (address => uint) withdrawTokensMap;  //For token withdraw function, maps a user address to the amount of tokens they can withdraw
  	mapping (address => uint256) excessEther;   //Catch for failed deposits. indicates how much a failed or overpaid user deposit paid

  	CrowdsaleToken token;
  }

  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
  event LogDepositWithdrawn(address indexed _bidder, uint256 Amount);
  event LogNoticeMsg(address indexed _from, string Msg);
  event LogErrorMsg(address indexed _from, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _decimals Decimal places for the token represented
  function init(CrowdsaleStorage storage self,
                address _owner,
                uint256 _tokenPrice,
                uint256 _capAmount,
                uint256 _minimumTargetRaise,
                uint256 _auctionSupply,
                uint8 _decimals,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _addressCap,
                CrowdsaleToken _token)
  {
  	require(self.auctionSupply == 0);
  	require(self.owner == 0);
  	require(_startTime >= now);
    require(_endTime > _startTime);
    require(_tokenPrice > 0);
    require(_capAmount > _minimumTargetRaise);
    require(_auctionSupply > 0);
    require(_addressCap > 0);
    self.owner = _owner;
    self.tokenPrice = _tokenPrice;
    self.capAmount = _capAmount;
    self.minimumTargetRaise = _minimumTargetRaise;
    self.auctionSupply = _auctionSupply;
    self.decimals = _decimals;
    self.startTime = _startTime;
    self.endTime = _endTime;
    self.addressCap = _addressCap;
    self.token = _token;
  }

  /// @dev function to check if the crowdsale is currently active
  function crowdsaleActive(CrowdsaleStorage storage self) constant returns (bool) {
  	return (now >= self.startTime && now <= self.endTime);
  }

  /// @dev function to check if the crowdsale has ended
  function crowdsaleEnded(CrowdsaleStorage storage self) constant returns (bool) {
  	return now > self.endTime;
  }

  ///  @dev function to check if a purchase is valid
  /// @return true if the transaction can buy tokens
  function validPurchase(CrowdsaleStorage storage self) constant returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    bool registered = self.isRegistered[msg.sender];
    return crowdsaleActive(self) && registered && nonZeroPurchase;
  }

  /// @dev Function called by purchasers to pull tokens
  function withdrawTokens(CrowdsaleStorage storage self) {
    var total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    bool ok = self.token.transferFrom(self.owner, msg.sender, total);
    if(ok) {
      LogTokensWithdrawn(msg.sender, total);
    }
  }

  /// @dev Function called by bidders to retrieve either their failed purchase ether or excess ether they sent
  function withdrawEther(CrowdsaleStorage storage self) {
    uint256 amount = self.excessEther[msg.sender];
    self.excessEther[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  /// @dev Function to change the price of the token
  /// @param _amount amount to increase the token price by
  /// @return success 
  function increaseTokenPrice(CrowdsaleStorage storage self, uint256 _amount) {
  	require(msg.sender == self.owner);
  	require(_amount > 0);
  	bool err;
  	uint256 newPrice;

  	(err,newPrice) = self.tokenPrice.plus(_amount);
  	require(!err);
  	self.tokenPrice = newPrice;
  }

  /// @dev Function to change the price of the token
  /// @param _amount amount to increase the token price by
  /// @return success 
  function decreaseTokenPrice(CrowdsaleStorage storage self, uint256 _amount) {
  	require(msg.sender == self.owner);
  	require(_amount > 0);
  	bool err;
  	uint256 newPrice;

  	(err,newPrice) = self.tokenPrice.minus(_amount);
  	require(!err);
  	self.tokenPrice = newPrice;
  }

  /// @dev Function to change the amount of ether that each account can spend in the sale
  /// @param _newCap new purchase cap for an account
  /// @return success 
  function changeAddressCap(CrowdsaleStorage storage self, uint256 _newCap) returns (bool) {
  	require(msg.sender == self.owner);
  	require(_newCap > self.addressCap);

  	self.addressCap = _newCap;

  }

}





















