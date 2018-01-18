pragma solidity ^0.4.18;

/**
 * @title InteractiveCrowdsaleLib
 * @author Modular, Inc
 *
 * version 1.0.0
 * Copyright (c) 2017 Modular, Inc
 * The MIT License (MIT)
 *
 * The InteractiveCrowdsale Library provides functionality to create a crowdsale
 * based on the white paper initially proposed by Jason Teutsch and Vitalik
 * Buterin. See https://people.cs.uchicago.edu/~teutsch/papers/ico.pdf for
 * further information.
 *
 * This library was developed in a collaborative effort among many organizations
 * including TrueBit, Modular, and Consensys.
 * For further information: truebit.io, modular.network,
 * consensys.net
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
import "./CrowdsaleLib.sol";
import "./LinkedListLib.sol";

library InteractiveCrowdsaleLib {
  using BasicMathLib for uint256;
  using TokenLib for TokenLib.TokenStorage;
  using LinkedListLib for LinkedListLib.LinkedList;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  // Node constants for use in the linked list
  uint256 constant NULL = 0;
  uint256 constant HEAD = 0;
  bool constant PREV = false;
  bool constant NEXT = true;

  struct InteractiveCrowdsaleStorage {

    CrowdsaleLib.CrowdsaleStorage base; // base storage from CrowdsaleLib

    // List of personal valuations, sorted from smallest to largest (from LinkedListLib)
    LinkedListLib.LinkedList valuationsList;

    // Info holder for token creation
    TokenLib.TokenStorage tokenInfo;

    uint256 endWithdrawalTime;   // time when manual withdrawals are no longer allowed

    // current total valuation of the sale
    // actual amount of ETH committed, taking into account partial purchases
    uint256 totalValuation;

    // amount of value committed at this valuation, cannot rely on owner balance
    // due to fluctations in commitment calculations needed after owner withdraws
    // in other words, the total amount of ETH committed, including total bids
    // that will eventually get partial purchases
    uint256 valueCommitted;

    // the bucket that sits either at or just below current total valuation.
    // determines where the cutoff point is for bids in the sale
    uint256 currentBucket;

    // the fraction of each minimal valuation bidder's ether refund, 'q' is from the paper
    // and is calculated when finalizing the sale
    uint256 q;

    // minimim amount that the sale needs to make to be successfull
    uint256 minimumRaise;

    // percentage of total tokens being sold in this sale
    uint8 percentBeingSold;

    // the bonus amount for early bidders.  This is a percentage of the base token
    // price that gets added on the the base token price used in getCurrentBonus()
    uint256 priceBonusPercent;

    // Indicates that the owner has finalized the sale and withdrawn Ether
    bool isFinalized;

    // Set to true if the sale is canceled
    bool isCanceled;

    // shows the price that the address purchased tokens at
    mapping (address => uint256) pricePurchasedAt;

    // the sums of bids at each valuation.  Used to calculate the current bucket for the valuation pointer
    mapping (uint256 => uint256) valuationSums;

    // the number of active bids at a certain valuation cap
    mapping (uint256 => uint256) numBidsAtValuation;

    // the valuation cap that each address has submitted
    mapping (address => uint256) personalCaps;

    // shows if an address has done a manual withdrawal. manual withdrawals are only allowed once
    mapping (address => bool) hasManuallyWithdrawn;
  }

  // Indicates when a bidder submits a bid to the crowdsale
  event LogBidAccepted(address indexed bidder, uint256 amount, uint256 personalValuation);

  // Indicates when a bidder manually withdraws their bid from the crowdsale
  event LogBidWithdrawn(address indexed bidder, uint256 amount, uint256 personalValuation);

  // Indicates when a bid is removed by the automated bid removal process
  event LogBidRemoved(address indexed bidder, uint256 personalValuation);

  // Generic Error Msg Event
  event LogErrorMsg(uint256 amount, string Msg);

  // Indicates when the price of the token changes
  event LogTokenPriceChange(uint256 amount, string Msg);

  // Logs the current bucket that the valuation points to, the total valuation of
  // the sale, and the amount of ETH committed, including total bids that will eventually get partial purchases
  event BucketAndValuationAndCommitted(uint256 bucket, uint256 valuation, uint256 committed);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item arrays such that, in each 3 element
  /// array index-0 is a timestamp, index-1 is price in tokens/ETH
  /// index-2 is address purchase cap at that time, 0 if no address cap
  /// @param _priceBonusPercent the bonus amount for early bidders
  /// @param _minimumRaise minimim amount that the sale needs to make to be successfull
  /// @param _endWithdrawalTime timestamp that indicates that manual withdrawals are no longer allowed
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBeingSold percentage of total tokens being sold in the sale
  /// @param _tokenName name of the token being sold. ex: "Jason Network Token"
  /// @param _tokenSymbol symbol of the token. ex: "JNT"
  /// @param _tokenDecimals number of decimals in the token
  /// @param _allowMinting whether or not to allow minting of the token after the sale
  function init(InteractiveCrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _priceBonusPercent,
                uint256 _minimumRaise,
                uint256 _endWithdrawalTime,
                uint256 _endTime,
                uint8 _percentBeingSold,
                string _tokenName,
                string _tokenSymbol,
                uint8 _tokenDecimals,
                bool _allowMinting) public
  {
    self.base.init(_owner,
                _saleData,
                _endTime,
                0, // no token burning for iico
                CrowdsaleToken(0)); // no tokens created prior to iico

    require(_endWithdrawalTime < _endTime);
    require(_endWithdrawalTime > _saleData[0]);
    require(_minimumRaise > 0);
    require(_percentBeingSold > 0);
    require(_percentBeingSold <= 100);
    require(_priceBonusPercent > 0);

    self.minimumRaise = _minimumRaise;
    self.endWithdrawalTime = _endWithdrawalTime;
    self.percentBeingSold = _percentBeingSold;
    self.priceBonusPercent = _priceBonusPercent;

    self.tokenInfo.name = _tokenName;
    self.tokenInfo.symbol = _tokenSymbol;
    self.tokenInfo.decimals = _tokenDecimals;
    self.tokenInfo.stillMinting = _allowMinting;
  }

  /// @dev calculates the number of digits in a given number
  /// @param _number the number for which we're caluclating digits
  /// @return _digits the number of digits in _number
  function numDigits(uint256 _number) public pure returns (uint256) {
    uint256 _digits = 0;
    while (_number != 0) {
      _number /= 10;
      _digits++;
    }
    return _digits;
  }

  /// @dev calculates the number of tokens purchased based on the amount of wei
  ///      spent and the price of tokens
  /// @param _amount amound of wei that the buyer sent
  /// @param _price price of tokens in the sale, in tokens/ETH
  /// @return uint256 numTokens the number of tokens purchased
  /// @return remainder  any remaining wei leftover from integer division
  function calculateTokenPurchase(uint256 _amount,
                                  uint256 _price)
                                  internal
                                  pure
                                  returns (uint256,uint256)
  {
    uint256 remainder = 0; //temp calc holder for division remainder for leftover wei

    bool err;
    uint256 numTokens;
    uint256 weiTokens; //temp calc holder

    // Find the number of tokens as a function in wei
    (err,weiTokens) = _amount.times(_price);
    require(!err);

    numTokens = weiTokens / 1000000000000000000;
    remainder = weiTokens % 1000000000000000000;
    remainder = remainder / _price;

    return (numTokens,remainder);
  }

  /// @dev Called when an address wants to submit a bid to the sale
  /// @param self Stored crowdsale from crowdsale contract
  /// @return currentBonus percentage of the bonus that is applied for the purchase
  function getCurrentBonus(InteractiveCrowdsaleStorage storage self) internal view returns (uint256){
    // can't underflow becuase endWithdrawalTime > startTime
    uint256 bonusTime = self.endWithdrawalTime - self.base.startTime;
    // can't underflow because now > startTime
    uint256 elapsed = now - self.base.startTime;
    uint256 percentElapsed = (elapsed * 100)/bonusTime;

    bool err;
    uint256 currentBonus;
    (err,currentBonus) = self.priceBonusPercent.minus(((percentElapsed * self.priceBonusPercent)/100));
    require(!err);

    return currentBonus;
  }

  /// @dev Called when an address wants to submit bid to the sale
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amound of wei that the buyer is sending
  /// @param _personalCap the total crowdsale valuation (wei) that the bidder is comfortable with
  /// @param _valuePredict prediction of where the valuation will go in the linked list. saves on searching time
  /// @return true on succesful bid
  function submitBid(InteractiveCrowdsaleStorage storage self,
                      uint256 _amount,
                      uint256 _personalCap,
                      uint256 _valuePredict) public returns (bool)
  {
    require(msg.sender != self.base.owner);
    require(self.base.validPurchase());
    // bidder can't have already bid
    require((self.personalCaps[msg.sender] == 0) && (self.base.hasContributed[msg.sender] == 0));

    uint256 _bonusPercent;
    // token purchase bonus only applies before the withdrawal lock
    if (now < self.endWithdrawalTime) {
      require(_personalCap > _amount);
      _bonusPercent = getCurrentBonus(self);
    } else {
      // The personal valuation submitted must be greater than the current
      // valuation plus the bid if after the withdrawal lock.
      require(_personalCap >= self.totalValuation + _amount);
    }

    // personal valuation and minimum should be set to the proper granularity,
    // only three most significant values can be non-zero. reduces the number of possible
    // valuation buckets in the linked list
    uint256 digits = numDigits(_personalCap);
    if(digits > 3) {
      require((_personalCap % (10**(digits - 3))) == 0);
    }

    // add the bid to the sorted valuations list
    // duplicate personal valuation caps share a spot in the linked list
    uint256 _listSpot;
    if(!self.valuationsList.nodeExists(_personalCap)){
        _listSpot = self.valuationsList.getSortedSpot(_valuePredict,_personalCap,NEXT);
        self.valuationsList.insert(_listSpot,_personalCap,PREV);
    }

    // add the bid to the address => cap mapping
    self.personalCaps[msg.sender] = _personalCap;

    // add the bid to the sum of bids at this valuation. Needed for calculating correct valuation pointer
    self.valuationSums[_personalCap] += _amount;
    self.numBidsAtValuation[_personalCap] += 1;

    // add the bid to bidder's contribution amount
    self.base.hasContributed[msg.sender] += _amount;

    // temp variables for calculation
    uint256 _proposedCommit;
    uint256 _currentBucket;
    bool loop;
    bool exists;

    // we only affect the pointer if we are coming in above it
    if(_personalCap > self.currentBucket){

      // if our valuation is sitting at the current bucket then we are using
      // commitments right at their cap
      if (self.totalValuation == self.currentBucket) {
        // we are going to drop those commitments to see if we are going to be
        // greater than the current bucket without them
        _proposedCommit = (self.valueCommitted - self.valuationSums[self.currentBucket]) + _amount;
        if(_proposedCommit > self.currentBucket){ loop = true; }
      } else {
        // else we're sitting in between buckets and have already dropped the
        // previous commitments
        _proposedCommit = self.totalValuation + _amount;
        loop = true;
      }

      if(loop){
        // if we're going to loop we move to the next bucket
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, NEXT);

        while(_proposedCommit >= _currentBucket){
          // while we are proposed higher than the next bucket we drop commitments
          // and iterate to the next
          _proposedCommit = _proposedCommit - self.valuationSums[_currentBucket];
          (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, NEXT);
        }
        // once we've reached a bucket too high we move back to the last bucket and set it
        (exists, _currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
        self.currentBucket = _currentBucket;
      } else {
        // else we're staying at the current bucket
        _currentBucket = self.currentBucket;
      }
      // if our proposed commitment is less than or equal to the bucket
      if(_proposedCommit <= _currentBucket){
        // we add the commitments in that bucket
        _proposedCommit += self.valuationSums[_currentBucket];
        // and our value is capped at that bucket
        self.totalValuation = _currentBucket;
      } else {
        // else our total value is in between buckets and it equals the total commitements
        self.totalValuation = _proposedCommit;
      }

      self.valueCommitted = _proposedCommit;
    } else if(_personalCap == self.totalValuation){
      self.valueCommitted += _amount;
    }

    self.pricePurchasedAt[msg.sender] = (self.base.tokensPerEth * (100 + _bonusPercent))/100;
    LogBidAccepted(msg.sender, _amount, _personalCap);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }


  /// @dev Called when an address wants to manually withdraw their bid from the
  ///      sale. puts their wei in the LeftoverWei mapping
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true on succesful
  function withdrawBid(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    // The sender has to have already bid on the sale
    require(self.personalCaps[msg.sender] > 0);

    uint256 refundWei;
    // cannot withdraw after compulsory withdraw period is over unless the bid's
    // valuation is below the cutoff
    if (now >= self.endWithdrawalTime) {
      require(self.personalCaps[msg.sender] < self.totalValuation);

      // full refund because their bid no longer affects the total sale valuation
      refundWei = self.base.hasContributed[msg.sender];

    } else {
      require(!self.hasManuallyWithdrawn[msg.sender]);  // manual withdrawals are only allowed once
      /***********************************************************************
      The following lines were commented out due to stack depth, but they represent
      the variables and calculations from the paper. The actual code is the same
      thing spelled out using current variables.  See section 4 of the white paper for formula used
      ************************************************************************/
      //uint256 t = self.endWithdrawalTime - self.base.startTime;
      //uint256 s = now - self.base.startTime;
      //uint256 pa = self.pricePurchasedAt[msg.sender];
      //uint256 pu = self.base.tokensPerEth;
      //uint256 multiplierPercent =  (100*(t - s))/t;
      //self.pricePurchasedAt = pa-((pa-pu)/3)

      uint256 multiplierPercent = (100 * (self.endWithdrawalTime - now)) /
                                  (self.endWithdrawalTime - self.base.startTime);
      refundWei = (multiplierPercent * self.base.hasContributed[msg.sender]) / 100;

      self.valuationSums[self.personalCaps[msg.sender]] -= refundWei;
      self.numBidsAtValuation[self.personalCaps[msg.sender]] -= 1;

      self.pricePurchasedAt[msg.sender] = self.pricePurchasedAt[msg.sender] -
                                          ((self.pricePurchasedAt[msg.sender] - self.base.tokensPerEth) / 3);

      self.hasManuallyWithdrawn[msg.sender] = true;

    }

    // Put the sender's contributed wei into the leftoverWei mapping for later withdrawal
    self.base.leftoverWei[msg.sender] += refundWei;

    // subtract the bidder's refund from its total contribution
    self.base.hasContributed[msg.sender] -= refundWei;


    uint256 _proposedCommit;
    uint256 _proposedValue;
    uint256 _currentBucket;
    bool loop;
    bool exists;

    // bidder's withdrawal only affects the pointer if the personal cap is at or
    // above the current valuation
    if(self.personalCaps[msg.sender] >= self.totalValuation){

      // first we remove the refundWei from the committed value
      _proposedCommit = self.valueCommitted - refundWei;

      // if we've dropped below the current bucket
      if(_proposedCommit <= self.currentBucket){
        // and current valuation is above the bucket
        if(self.totalValuation > self.currentBucket){
          _proposedCommit += self.valuationSums[self.currentBucket];
        }

        if(_proposedCommit >= self.currentBucket){
          _proposedValue = self.currentBucket;
        } else {
          // if we are still below the current bucket then we need to iterate
          loop = true;
        }
      } else {
        if(self.totalValuation == self.currentBucket){
          _proposedValue = self.totalValuation;
        } else {
          _proposedValue = _proposedCommit;
        }
      }

      if(loop){
        // if we're going to loop we move to the previous bucket
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, PREV);
        while(_proposedCommit <= _currentBucket){
          // while we are proposed lower than the previous bucket we add commitments
          _proposedCommit += self.valuationSums[_currentBucket];
          // and iterate to the previous
          if(_proposedCommit >= _currentBucket){
            _proposedValue = _currentBucket;
          } else {
            (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
          }
        }

        if(_proposedValue == 0) { _proposedValue = _proposedCommit; }

        self.currentBucket = _currentBucket;
      }

      self.totalValuation = _proposedValue;
      self.valueCommitted = _proposedCommit;
    }

    LogBidWithdrawn(msg.sender, refundWei, self.personalCaps[msg.sender]);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }

  /// @dev This should be called once the sale is over to commit all bids into
  ///      the owner's bucket.
  /// @param self stored crowdsale from crowdsale contract
  function finalizeSale(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(now >= self.base.endTime);
    require(!self.isFinalized); // can only be called once
    require(setCanceled(self));

    self.isFinalized = true;
    require(launchToken(self));
    // may need to be computed due to EVM rounding errors
    uint256 computedValue;

    if(!self.isCanceled){
      if(self.totalValuation == self.currentBucket){
        // calculate the fraction of each minimal valuation bidders ether and tokens to refund
        self.q = (100*(self.valueCommitted - self.totalValuation)/(self.valuationSums[self.totalValuation])) + 1;
        computedValue = self.valueCommitted - self.valuationSums[self.totalValuation];
        computedValue += (self.q * self.valuationSums[self.totalValuation])/100;
      } else {
        // no computation necessary
        computedValue = self.totalValuation;
      }
      self.base.ownerBalance = computedValue;  // sets ETH raised in the sale to be ready for withdrawal
    }
  }

  /// @dev Mints the token being sold by taking the percentage of the token supply
  ///      being sold in this sale along with the valuation, derives all necessary
  ///      values and then transfers owner tokens to the owner.
  /// @param self Stored crowdsale from crowdsale contract
  function launchToken(InteractiveCrowdsaleStorage storage self) internal returns (bool) {
    // total valuation of all the tokens not including the bonus
    uint256 _fullValue = (self.totalValuation*100)/uint256(self.percentBeingSold);
    // total valuation of bonus tokens
    uint256 _bonusValue = ((self.totalValuation * (100 + self.priceBonusPercent))/100) - self.totalValuation;
    // total supply of all tokens not including the bonus
    uint256 _supply = (_fullValue * self.base.tokensPerEth)/1000000000000000000;
    // total number of bonus tokens
    uint256 _bonusTokens = (_bonusValue * self.base.tokensPerEth)/1000000000000000000;
    // tokens allocated to the owner of the sale
    uint256 _ownerTokens = _supply - ((_supply * uint256(self.percentBeingSold))/100);
    // total supply of tokens not including the bonus tokens
    uint256 _totalSupply = _supply + _bonusTokens;

    // deploy new token contract with total number of tokens
    self.base.token = new CrowdsaleToken(address(this),
                                         self.tokenInfo.name,
                                         self.tokenInfo.symbol,
                                         self.tokenInfo.decimals,
                                         _totalSupply,
                                         self.tokenInfo.stillMinting);

    // if the sale got canceled, then all the tokens go to the owner and bonus tokens are burned
    if(!self.isCanceled){
      self.base.token.transfer(self.base.owner, _ownerTokens);
    } else {
      self.base.token.transfer(self.base.owner, _supply);
      self.base.token.burnToken(_bonusTokens);
    }
    // the owner of the crowdsale becomes the new owner of the token contract
    self.base.token.changeOwner(self.base.owner);
    self.base.startingTokenBalance = _supply - _ownerTokens;

    return true;
  }

  /// @dev returns a boolean indicating if the sale is canceled.
  ///      This can either be if the minimum raise hasn't been met
  ///      or if it is 30 days after the sale and the owner hasn't finalized the sale.
  /// @return bool canceled indicating if the sale is canceled or not
  function setCanceled(InteractiveCrowdsaleStorage storage self) internal returns(bool){
    bool canceled = (self.totalValuation < self.minimumRaise) ||
                    ((now > (self.base.endTime + 30 days)) && !self.isFinalized);

    if(canceled) {self.isCanceled = true;}

    return true;
  }

  /// @dev If the address' personal cap is below the pointer, refund them all their ETH.
  ///      if it is above the pointer, calculate tokens purchased and refund leftoever ETH
  /// @param self Stored crowdsale from crowdsale contract
  /// @return bool success if the contract runs successfully
  function retreiveFinalResult(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(now > self.base.endTime);
    require(self.personalCaps[msg.sender] > 0);

    uint256 numTokens;
    uint256 remainder;

    if(!self.isFinalized){
      require(setCanceled(self));
      require(self.isCanceled);
    }

    if (self.isCanceled) {
      // if the sale was canceled, everyone gets a full refund
      self.base.leftoverWei[msg.sender] += self.base.hasContributed[msg.sender];
      self.base.hasContributed[msg.sender] = 0;
      LogErrorMsg(self.totalValuation, "Sale is canceled, all bids have been refunded!");
      return true;
    }

    if (self.personalCaps[msg.sender] < self.totalValuation) {

      // full refund if personal cap is less than total valuation
      self.base.leftoverWei[msg.sender] += self.base.hasContributed[msg.sender];

      // set hasContributed to 0 to prevent participant from calling this over and over
      self.base.hasContributed[msg.sender] = 0;

      return self.base.withdrawLeftoverWei();

    } else if (self.personalCaps[msg.sender] == self.totalValuation) {

      // calculate the portion that this address has to take out of their bid
      uint256 refundAmount = (self.q*self.base.hasContributed[msg.sender])/100;

      // refund that amount of wei to the address
      self.base.leftoverWei[msg.sender] += refundAmount;

      // subtract that amount the address' contribution
      self.base.hasContributed[msg.sender] -= refundAmount;
    }

    LogErrorMsg(self.base.hasContributed[msg.sender],"contribution");
    LogErrorMsg(self.pricePurchasedAt[msg.sender],"price");
    LogErrorMsg(self.q,"percentage");
    // calculate the number of tokens that the bidder purchased
    (numTokens, remainder) = calculateTokenPurchase(self.base.hasContributed[msg.sender],
                                                    self.pricePurchasedAt[msg.sender]);

    // add tokens to the bidders purchase.  can't overflow because it will be under the cap
    self.base.withdrawTokensMap[msg.sender] += numTokens;
    self.valueCommitted = self.valueCommitted - remainder;
    self.base.leftoverWei[msg.sender] += remainder;

    // burn any extra bonus tokens
    uint256 _fullBonus;
    uint256 _fullBonusPrice = (self.base.tokensPerEth*(100 + self.priceBonusPercent))/100;
    (_fullBonus, remainder) = calculateTokenPurchase(self.base.hasContributed[msg.sender], _fullBonusPrice);
    uint256 _leftoverBonus = _fullBonus - numTokens;
    self.base.token.burnToken(_leftoverBonus);

    self.base.hasContributed[msg.sender] = 0;

    // send tokens and leftoverWei to the address calling the function
    self.base.withdrawTokens();

    self.base.withdrawLeftoverWei();

  }



   /*Functions "inherited" from CrowdsaleLib library*/

  function withdrawLeftoverWei(InteractiveCrowdsaleStorage storage self) internal returns (bool) {

    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(InteractiveCrowdsaleStorage storage self) internal returns (bool) {

    return self.base.withdrawOwnerEth();
  }

  function crowdsaleActive(InteractiveCrowdsaleStorage storage self) internal view returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(InteractiveCrowdsaleStorage storage self) internal view returns (bool) {
    return self.base.crowdsaleEnded();
  }

  function getPersonalCap(InteractiveCrowdsaleStorage storage self, address _bidder) internal view returns (uint256) {
    return self.personalCaps[_bidder];
  }

  function getTokensSold(InteractiveCrowdsaleStorage storage self) internal view returns (uint256) {
    return self.base.getTokensSold();
  }

}
