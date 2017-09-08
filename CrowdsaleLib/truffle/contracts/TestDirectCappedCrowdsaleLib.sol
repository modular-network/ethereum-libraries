pragma solidity ^0.4.13;

// /**
//  * @title DirectCrowdsaleLib
//  * @author Majoolr.io
//  *
//  * version 1.0.0
//  * Copyright (c) 2017 Majoolr, LLC
//  * The MIT License (MIT)
//  * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
//  *
//  * The DirectCrowdsale Library provides functionality to create a initial coin offering
//  * for a standard token sale with high supply where there is a direct ether to
//  * token transfer.  
//  * See https://github.com/Majoolr/ethereum-contracts for an example of how to
//  * create a basic ERC20 token.
//  *
//  * Majoolr works on open source projects in the Ethereum community with the
//  * purpose of testing, documenting, and deploying reusable code onto the
//  * blockchain to improve security and usability of smart contracts. Majoolr
//  * also strives to educate non-profits, schools, and other community members
//  * about the application of blockchain technology.
//  * For further information: majoolr.io
//  *
//  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  */

// import "./BasicMathLib.sol";
// import "./TokenLib.sol";
// import "./TestCrowdsaleLib.sol";

// library TestDirectCrowdsaleLib {
//   using BasicMathLib for uint256;
//   using TestCrowdsaleLib for TestCrowdsaleLib.CrowdsaleStorage;

//   struct DirectCrowdsaleStorage {

//   	TestCrowdsaleLib.CrowdsaleStorage base;

//     uint256 minimumTargetRaise; //Minimum amount acceptable for successful auction in wei

//   	uint256 periodicChange;    // amount in ether that the token price changes after a specified interval
//   	uint256 timeInterval;      // amount of time between changes in the price of the token
//   	uint256 currDay;          // current Day
//     uint256 ownerBalance;

//     mapping (address => uint256) excessEther;   //Catch for failed deposits. indicates how much a failed or overpaid user deposit paid

//   	bool increase;             // true if the price of the token increases, false if it decreases
//   }

//   event LogTokensBought(address indexed buyer, uint256 amount);
//   event LogAddressCapExceeded(address indexed buyer, uint256 amount, string Msg);
//   event LogOwnerWithdrawl(address indexed owner, uint256 amount, string Msg);

//   // event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
//   // event LogDepositWithdrawn(address indexed _bidder, uint256 Amount);
//   // event LogNoticeMsg(address indexed _from, string Msg);
//   event LogErrorMsg(uint256 amount, string Msg);


//   /// @dev Called by a crowdsale contract upon creation.
//   /// @param self Stored crowdsale from crowdsale contract
//   function init(DirectCrowdsaleStorage storage self,
//                 address _owner,
//                 uint256 _currtime,
//                 uint256 _tokenPrice,
//                 uint256 _capAmount,
//                 uint256 _minimumTargetRaise,
//                 uint256 _auctionSupply,
//                 uint256 _startTime,
//                 uint256 _endTime,
//                 uint256 _addressCap,
//                 uint256 _periodicChange,
//                 uint256 _timeInterval,
//                 bool _increase,
//                 CrowdsaleToken _token)
//   {
//   	self.base.init(_owner,
//                 _currtime,
//                 _tokenPrice,
//                 _capAmount,
//                 _minimumTargetRaise,
//                 _auctionSupply,
//                 _startTime,
//                 _endTime,
//                 _addressCap,
//                 _token);

//     if (_periodicChange == 0) {             // if there is no increase or decrease in price, the time interval should also be zero
//     	require(_timeInterval == 0);
//     }
//   	self.periodicChange = _periodicChange;
//   	self.timeInterval = _timeInterval; 
//   	self.increase = _increase;
//   	self.currDay = _startTime;
//     self.ownerBalance = 0;
//   }

//   /// @dev Called when an address wants to purchase tokens
//   /// @param self Stored crowdsale from crowdsale contract
//   /// @param _amount amound of wei that the buyer is sending
//   function receivePurchase(DirectCrowdsaleStorage storage self, uint256 _amount, uint256 currtime) returns (bool) {
//     require(msg.sender != self.base.owner);
//     if (!self.base.validPurchase(currtime)) {   //NEEDS TO BE A REQUIRE
//       return false;
//     }
//   	//require(self.base.validPurchase());
//   	require(self.base.hasContributed[msg.sender] < self.base.addressCap);
//   	require(self.ownerBalance < self.base.capAmount);

//   	// if the token price increase interval has passed, update the current day and change the token price
//   	if ((self.timeInterval > 0) && (currtime > (self.currDay + self.timeInterval))) {
//   		self.currDay = currtime;
//   		if (self.increase) { self.base.increaseTokenPrice(self.periodicChange); }
//   		else { self.base.decreaseTokenPrice(self.periodicChange); }
//   	}

//   	uint256 numTokens;     //number of tokens that will be purchased
//   	bool err;
//     uint256 newBalance;    //the new balance of the owner of the crowdsale
//     uint256 etherContributed;

//   	// if the sender over pays their allocated contribution, put the leftover ether into a mapping for their address that they can withdraw later
//   	if ((self.base.addressCap != 0 ) && (self.base.hasContributed[msg.sender] + _amount > self.base.addressCap)) {
// 		  uint256 leftoverWei = _amount - (self.base.addressCap-self.base.hasContributed[msg.sender]);
// 		  uint256 amountContributed = _amount-leftoverWei;
//       (err,etherContributed) = amountContributed.dividedBy(100000000000000000000);
//       require(!err);
// 		  self.base.hasContributed[msg.sender] += amountContributed;     // can't overflow because it will be under the cap
// 		  self.base.excessEther[msg.sender].plus(leftoverWei);				   
// 		  (err,numTokens) = etherContributed.times(self.base.tokenPrice);

//       require(!err);

//       (err,newBalance) = self.ownerBalance.plus(amountContributed);
//       require(!err);
//       self.ownerBalance = newBalance;

// 		  require(!err);

//       LogAddressCapExceeded(msg.sender,leftoverWei, "Amount sent exceeded the contribution cap per address.  Please withdraw excess Ether!");

// 	  } else {
// 		  self.base.hasContributed[msg.sender] += _amount;      // can't overflow because it is under the cap
//       (err,etherContributed) = _amount.dividedBy(1000000000000000000);

//       require(!err);

// 		  (err,numTokens) = etherContributed.times(self.base.tokenPrice);

// 		  require(!err);

//       (err,newBalance) = self.ownerBalance.plus(_amount);
//       require(!err);
//       self.ownerBalance = newBalance;
//       LogErrorMsg(_amount, "HERE!");
// 	  }

// 	  self.base.withdrawTokensMap[msg.sender] += numTokens;    // can't overflow because it will be under the cap

// 	  LogTokensBought(msg.sender, numTokens);

//     return true;

//   }

//   /// @dev send ether from a purchase to the owners wallet address
//   function ownerWithdrawl(DirectCrowdsaleStorage storage self, uint256 currtime) internal {
//     require(msg.sender == self.base.owner);
//     require(self.base.crowdsaleEnded(currtime));
//     require(self.ownerBalance > 0);

//     uint256 amount = self.ownerBalance;
//     self.ownerBalance = 0;
//     msg.sender.transfer(amount);
//     LogOwnerWithdrawl(msg.sender,amount,"crowdsale owner has withdrawn all funds");
//   }

//     /// @dev Function called by bidders to retrieve either their failed purchase ether or excess ether they sent
//   /// @param self Stored crowdsale from crowdsale contract
//   function withdrawEther(CrowdsaleStorage storage self) returns (bool) {
//     if (self.excessEther[msg.sender] == 0) {
//       LogErrorMsg("sender has no excess ether to withdraw!");
//       return false;
//     }

//     uint256 amount = self.excessEther[msg.sender];
//     self.excessEther[msg.sender] = 0;
//     msg.sender.transfer(amount);
//     return true;
//   }
 
//     /// @dev Function to change the amount of ether that each account can spend in the sale
//   /// @param _newCap new purchase cap for an account
//   /// @return success 
//   function changeAddressCap(CrowdsaleStorage storage self, uint256 _newCap, uint256 currtime) returns (bool) {
//     if (crowdsaleEnded(self, currtime)) {
//       LogErrorMsg("Cannot change the address cap. Crowdsale is over");
//       return false;
//     }
//    require(msg.sender == self.owner);
//    require(_newCap > self.addressCap);

//    self.addressCap = _newCap;

//     return true;
//   }

//   ///  Functions "inherited" from CrowdsaleLib library


//   function crowdsaleActive(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
//     return self.base.crowdsaleActive(currtime);
//   }

//   function crowdsaleEnded(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
//     return self.base.crowdsaleEnded(currtime);
//   }

//   function validPurchase(DirectCrowdsaleStorage storage self, uint256 currtime) constant returns (bool) {
//     return self.base.validPurchase(currtime);
//   }

//   function withdrawTokens(DirectCrowdsaleStorage storage self, uint256 currtime) returns (bool) {
//     return self.base.withdrawTokens(currtime);
//   }

//   function withdrawEther(DirectCrowdsaleStorage storage self) returns (bool) {
//     return self.base.withdrawEther();
//   }

//   function increaseTokenPrice(DirectCrowdsaleStorage storage self, uint256 _amount) {
//     self.base.increaseTokenPrice(_amount);
//   }

//   function decreaseTokenPrice(DirectCrowdsaleStorage storage self, uint256 _amount) {
//     self.base.decreaseTokenPrice(_amount);
//   }

//   function changeAddressCap(DirectCrowdsaleStorage storage self, uint256 _newCap, uint256 currtime) returns (bool) {
//     return self.base.changeAddressCap(_newCap,currtime);
//   }

//   function getContribution(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
//     return self.base.getContribution(_buyer);
//   }

//   function getTokenPurchase(DirectCrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
//     return self.base.getTokenPurchase(_buyer);
//   }

//   /// @dev Gets the amount of ether that is leftover after an account has purchased tokens
//   /// @param _buyer address to get the information for
//   /// @return amount of ether leftover from their purchases 
//   function getExcessEther(CrowdsaleStorage storage self, address _buyer) constant returns (uint256) {
//     require(self.hasContributed[_buyer] > 0);
//     return self.excessEther[_buyer];
//   }



// }
