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

contract TimeEvenDistroCrowdsaleTestContract2 {
  using TestEvenDistroCrowdsaleLib for TestEvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage;

  TestEvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage sale;

  function TimeEvenDistroCrowdsaleTestContract2(
                address owner,
                uint256 currtime,
                uint256[] saleData,
                uint256 fallbackExchangeRate,
                uint256 capAmountInCents,
                uint256 endTime,
                uint8 percentBurn,
                uint256 initialAddressTokenCap,
                bool staticCap,
                CrowdsaleToken token)
  {
  	sale.init(owner, currtime, saleData, fallbackExchangeRate, capAmountInCents, endTime, percentBurn, initialAddressTokenCap, staticCap, token);
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

  function registerUsers(address[] _registrants, uint256 _currtime) returns (bool) {
    return sale.registerUsers(_registrants, _currtime);
  }

  function unregisterUser(address _registrant, uint256 _currtime) returns (bool) {
    return sale.unregisterUser(_registrant, _currtime);
  }

  function unregisterUsers(address[] _registrants, uint256 _currtime) returns (bool) {
    return sale.unregisterUsers(_registrants, _currtime);
  }

  function isRegistered(address _registrant) constant returns (bool) {
    return sale.isRegistered[_registrant];
  }

  function withdrawTokens(uint256 currtime) returns (bool) {
  	return sale.withdrawTokens(currtime);
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
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

  function setTokens() returns (bool) {
    return sale.setTokens();
  }

  function getOwner() constant returns (address) {
    return sale.base.owner;
  }

  function getTokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function getExchangeRate() constant returns (uint256) {
    return sale.base.exchangeRate;
  }

  function getCapAmount() constant returns (uint256) {
    return sale.base.capAmount;
  }

  function getStartTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function getEndTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function getEthRaised() constant returns (uint256) {
    return sale.base.ownerBalance;
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

  function getSaleData(uint256 timestamp) constant returns (uint256[3]) {
    return sale.getSaleData(timestamp);
  }

  function getTokensSold() constant returns (uint256) {
    return sale.getTokensSold();
  }

  function getPercentBurn() constant returns (uint256) {
    return sale.base.percentBurn;
  }

  function getAddressTokenCap() constant returns (uint256) {
    return sale.addressTokenCap;
  }

  function getNumRegistered() constant returns (uint256) {
    return sale.numRegistered;
  }
}
