pragma solidity ^0.4.15;

/*****
*
*  Test contract for tesing the crowdsale libraries with testrpc
*
*  Uses currtime, a replacement for now in the library functions
*
******/


import "./TestEvenDistroCrowdsaleLib.sol";
import "./CrowdsaleToken.sol";

contract TimeEvenDistroCrowdsaleTestContract {
  using TestEvenDistroCrowdsaleLib for TestEvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage;

  TestEvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage sale;

  function TimeEvenDistroCrowdsaleTestContract(
                address owner,
                uint256 currtime,
                uint256 capAmountInCents,
                uint256 startTime,
                uint256 endTime,
                uint256 tokenPriceinCents,
                uint256 fallbackExchangeRate,
                uint256 capPercentMultiplier,
                uint256 changeInterval,
                uint8 percentBurn,
                CrowdsaleToken token)
  {
  	sale.init(owner, currtime, capAmountInCents, startTime, endTime, tokenPriceinCents, fallbackExchangeRate, changeInterval, percentBurn, capPercentMultiplier, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    //receivePurchase();
  }

  function receivePurchase(uint256 currtime) payable returns (bool) {
  	return sale.receivePurchase(msg.value, currtime);
  }

  function registerUser(address _registrant, uint256 _currtime) returns (bool) {
    return sale.registerUser(_registrant, _currtime);
  }

  function unregisterUser(address _registrant, uint256 _currtime) returns (bool) {
    return sale.unregisterUser(_registrant, _currtime);
  }

  function isRegistered(address _registrant) constant returns (bool) {
    return sale.isRegistered[_registrant];
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

  function addressCap() constant returns (uint256) {
    return sale.addressCap;
  }

  function numRegistered() constant returns (uint256) {
    return sale.numRegistered;
  }

  function capPercentMultiplier() constant returns (uint256) {
    return sale.capPercentMultiplier;
  }

  function ownerBalance() constant returns (uint256) {
    return sale.base.ownerBalance;
  }

  function percentBurn() constant returns (uint256) {
    return sale.base.percentBurn;
  }

  function withdrawOwnerEth(uint256 currtime) returns (bool) {
  	return sale.withdrawOwnerEth(currtime);
  }

  function crowdsaleActive(uint256 currtime) constant returns (bool) {
  	return sale.crowdsaleActive(currtime);
  }

  function crowdsaleEnded(uint256 currtime) constant returns (bool) {
  	return sale.crowdsaleEnded(currtime);
  }

  function setTokenExchangeRate(uint256 _exchangeRate, uint256 _currtime) returns (bool) {
    return sale.setTokenExchangeRate(_exchangeRate, _currtime);
  }

  function withdrawTokens(uint256 currtime) returns (bool) {
  	return sale.withdrawTokens(currtime);
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function getContribution(address _buyer) constant returns (uint256) {
    return sale.base.hasContributed[_buyer];
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
    return sale.base.withdrawTokensMap[_buyer];
  }

  function getLeftoverWei(address _buyer) constant returns (uint256) {
    return sale.base.leftoverWei[_buyer];
  }
}
