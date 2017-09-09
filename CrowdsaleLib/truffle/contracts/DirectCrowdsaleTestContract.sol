pragma solidity ^0.4.13;

/****************
*
*  Test contract for tesing libraries on networks
*
*****************/

import "./DirectCrowdsaleLib.sol";
import "./CrowdsaleToken.sol";

contract DirectCrowdsaleTestContract {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;

  function DirectCrowdsaleTestContract(
                address owner,
                uint256 tokensPerEth,
                uint256 capAmount,
                uint256 minimumTargetRaise,
                uint256 startTime,
                uint256 endTime,
                uint256 periodicChange,
                uint256 changeInterval,
                bool increase,
                CrowdsaleToken token)
  {
  	sale.init(owner, tokensPerEth, capAmount, minimumTargetRaise, startTime, endTime, periodicChange, changeInterval, increase, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    receivePurchase();
  }

  function receivePurchase() payable returns (bool) {
  	return sale.receivePurchase(msg.value);
  }

  function owner() constant returns (address) {
    return sale.base.owner;
  }

  function tokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function capAmount() constant returns (uint256) {
    return sale.base.capAmount;
  }

  function minimumTargetRaise() constant returns (uint256) {
    return sale.minimumTargetRaise;
  }

  function startTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function endTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function periodicChange() constant returns (uint256) {
    return sale.periodicChange;
  }

  function changeInterval() constant returns (uint256) {
    return sale.changeInterval;
  }

  function increase() constant returns (bool) {
    return sale.increase;
  }

  function ownerBalance() constant returns (uint256) {
  	return sale.ownerBalance;
  }

  function ownerWithdrawl() returns (bool) {
  	return sale.ownerWithdrawl();
  }

  function crowdsaleActive() constant returns (bool) {
  	return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
  	return sale.crowdsaleEnded();
  }

  function withdrawTokens() returns (bool) {
  	return sale.withdrawTokens();
  }

  function getContribution(address _buyer) constant returns (uint256) {
  	return sale.getContribution(_buyer);
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
  	return sale.getTokenPurchase(_buyer);
  }

}






