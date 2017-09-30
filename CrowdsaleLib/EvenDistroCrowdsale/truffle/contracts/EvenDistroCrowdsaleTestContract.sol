pragma solidity ^0.4.15;

/****************
*
*  Test contract for tesing libraries on networks
*
*****************/

import "./EvenDistroCrowdsaleLib.sol";
import "./CrowdsaleToken.sol";

contract EvenDistroCrowdsaleTestContract {
  using EvenDistroCrowdsaleLib for EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage;

  EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage sale;

  function EvenDistroCrowdsaleTestContract(
                address owner,
                uint256 capAmountInCents,
                uint256 startTime,
                uint256 endTime,
                uint256 tokenPriceinCents,
                uint256 fallbackExchangeRate,
                uint256 capPercentMultiplier,
                uint256 fallbackAddressCap,
                uint256 changeInterval,
                uint8 percentBurn,
                CrowdsaleToken token)
  {
  	sale.init(owner, capAmountInCents, startTime, endTime, tokenPriceinCents, fallbackExchangeRate, changeInterval, percentBurn, capPercentMultiplier, fallbackAddressCap, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    receivePurchase();
  }

  function receivePurchase() payable returns (bool) {
  	return sale.receivePurchase(msg.value);
  }

  function registerUser(address _registrant) returns (bool) {
    return sale.registerUser(_registrant);
  }

  function unregisterUser(address _registrant) returns (bool) {
    return sale.unregisterUser(_registrant);
  }

  function isRegistered(address _registrant) constant returns (bool) {
    return sale.isRegistered[_registrant];
  }

  function withdrawOwnerEth() returns (bool) {
  	return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() constant returns (bool) {
  	return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
  	return sale.crowdsaleEnded();
  }

  function setTokenExchangeRate(uint256 _exchangeRate) returns (bool) {
    return sale.setTokenExchangeRate(_exchangeRate);
  }

  function setTokens() returns (bool) {
    return sale.setTokens();
  }

  function withdrawTokens() returns (bool) {
  	return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
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
