pragma solidity ^0.4.15;

/*****
*
*  Test contract for tesing the crowdsale libraries with testrpc
*
*  Uses currprice, a replacement for now in the library functions
*
******/


import "./TestDirectCrowdsaleLib.sol";
import "./CrowdsaleToken.sol";

contract TimeDirectCrowdsaleTestContract {
  using TestDirectCrowdsaleLib for TestDirectCrowdsaleLib.DirectCrowdsaleStorage;

  TestDirectCrowdsaleLib.DirectCrowdsaleStorage sale;

  function TimeDirectCrowdsaleTestContract(
                address owner,
                uint256 currtime,
                uint256 tokenPriceinCents,
                uint256 capAmount,
                uint256 startTime,
                uint256 endTime,
                uint256[] tokenPricePoints,
                uint256 changeInterval,
                CrowdsaleToken token)
  {
  	sale.init(owner, currtime, tokenPriceinCents, capAmount, startTime, endTime, tokenPricePoints, changeInterval, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    //receivePurchase();
  }

  function receivePurchase(uint256 currtime) payable returns (bool) {
  	return sale.receivePurchase(msg.value, currtime);
  }

  function owner() constant returns (address) {
    return sale.base.owner;
  }

  function tokenPriceinCents() constant returns (uint256) {
    return sale.base.tokenPriceinCents;
  }

  function tokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
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
    return sale.ownerBalance;
  }

  function ownerWithdrawl(uint256 currtime) returns (bool) {
  	return sale.ownerWithdrawl(currtime);
  }

  function crowdsaleActive(uint256 currtime) constant returns (bool) {
  	return sale.crowdsaleActive(currtime);
  }

  function firstPriceChange() constant returns (uint256) {
    return sale.tokenPricePoints[0];
  }

  function crowdsaleEnded(uint256 currtime) constant returns (bool) {
  	return sale.crowdsaleEnded(currtime);
  }

  function setExchangeRate(uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    return sale.setExchangeRate(_exchangeRate, _currtime);
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






