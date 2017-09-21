pragma solidity ^0.4.15;

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
                uint256 capAmountInCents,
                uint256 startTime,
                uint256 endTime,
                uint256[] tokenPricePoints,
                uint256 fallbackExchangeRate,
                uint256 changeInterval,
                uint8 percentBurn,
                CrowdsaleToken token)
  {
  	sale.init(owner, capAmountInCents, startTime, endTime, tokenPricePoints, fallbackExchangeRate, changeInterval, percentBurn, token);
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

  function exchangeRate() constant returns (uint256) {
    return sale.base.exchangeRate;
  }

  function capAmount() constant returns (uint256) {
    return sale.base.capAmount;
  }

  function startTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function endTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function changeInterval() constant returns (uint256) {
    return sale.changeInterval;
  }

  function ownerBalance() constant returns (uint256) {
    return sale.base.ownerBalance;
  }

  function withdrawOwnerEth() returns (bool) {
  	return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() constant returns (bool) {
  	return sale.crowdsaleActive();
  }

  function firstPriceChange() constant returns (uint256) {
    return sale.tokenPricePoints[1];
  }

  function crowdsaleEnded() constant returns (bool) {
  	return sale.crowdsaleEnded();
  }

  function setTokenExchangeRate(uint256 _exchangeRate) returns (bool) {
    return sale.setTokenExchangeRate(_exchangeRate);
  }

  function withdrawTokens() returns (bool) {
  	return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function getContribution(address _buyer) constant returns (uint256) {
  	return sale.getContribution(_buyer);
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
  	return sale.getTokenPurchase(_buyer);
  }

  function getLeftoverWei(address _buyer) constant returns (uint256) {
    return sale.getLeftoverWei(_buyer);
  }
}
