pragma solidity ^0.4.13;

import "./DirectCrowdsaleLib.sol";
import "./CrowdsaleToken.sol";

contract DirectCrowdsaleTestContract {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;

  function DirectCrowdsaleTestContract(
                address owner,
                // uint256 tokenPrice,
                // uint256 capAmount,
                // uint256 minimumTargetRaise,
                // uint256 auctionSupply,
                // uint8 decimals,
                // uint256 startTime,
                // uint256 endTime,
                // uint256 addressCap,
                uint256 periodicChange,
                uint256 timeInterval,
                bool increase,
                CrowdsaleToken token)
  {
  	sale.init(owner, 100000000000000, 1000000000000000000000, 300000000000000000000, 800000, 18, now + 1 seconds, now + 20 seconds, 100000000000000000000, periodicChange, timeInterval, increase, token);
  	  		//tokenPrice, capAmount, minimumTargetRaise, auctionSupply, decimals, startTime, endTime, addressCap, periodicChange, timeInterval, increase, CrowdsaleToken token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    receivePurchase();
  }

  function receivePurchase() payable {
  	sale.receivePurchase(msg.value);
  }

  function owner() constant returns (address) {
    return sale.base.owner;
  }

  function tokenPrice() constant returns (uint256) {
    return sale.base.tokenPrice;
  }

  function capAmount() constant returns (uint256) {
    return sale.base.capAmount;
  }

  function minimumTargetRaise() constant returns (uint256) {
    return sale.base.minimumTargetRaise;
  }

  function auctionSupply() constant returns (uint256) {
    return sale.base.auctionSupply;
  }

  function decimals() constant returns (uint8) {
    return sale.base.decimals;
  }

  function startTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function endTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function addressCap() constant returns (uint256) {
    return sale.base.addressCap;
  }

  function periodicChange() constant returns (uint256) {
    return sale.periodicChange;
  }

  function timeInterval() constant returns (uint256) {
    return sale.timeInterval;
  }

  function increase() constant returns (bool) {
    return sale.increase;
  }

  function crowdsaleActive() constant returns (bool) {
  	return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
  	return sale.crowdsaleEnded();
  }

  function withdrawTokens() {
  	sale.withdrawTokens();
  }

  function withdrawEther() {
  	sale.withdrawEther();
  }

  function increaseTokenPrice(uint256 _amount) {
  	sale.increaseTokenPrice(_amount);
  }

  function decreaseTokenPrice(uint256 _amount) {
  	sale.decreaseTokenPrice(_amount);
  }

  function changeAddressCap(uint256 _newCap) {
  	sale.changeAddressCap(_newCap);
  }

  function getContribution(address _buyer) {
  	sale.getContribution(_buyer);
  }

  function getTokenPurchase(address _buyer) {
  	sale.getTokenPurchase(_buyer);
  }

  function getExcessEther(address _buyer) {
  	sale.getExcessEther(_buyer);
  }

}






