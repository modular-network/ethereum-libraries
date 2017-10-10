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
    uint256[] saleData,
    uint256 fallbackExchangeRate,
    uint256 capAmountInCents,
    uint256 endTime,
    uint8 percentBurn,
    uint256 initialAddressTokenCap,
    bool staticCap,
    CrowdsaleToken token)
  {
  	sale.init(owner, saleData, fallbackExchangeRate, capAmountInCents, endTime, percentBurn, initialAddressTokenCap, staticCap, token);
  }

  event LogTokensBought(address indexed buyer, uint256 amount, uint256 time);
  event LogAddressTokenCapExceeded(address indexed buyer, uint256 amount, string Msg);
  event LogUserRegistered(address registrant);
  event LogUserUnRegistered(address registrant);
  event LogErrorMsg(address user, string Msg);
  event LogAddressTokenCapChange(uint256 amount, string Msg);
  event LogTokenPriceChange(uint256 amount, string Msg);
  event LogAddressTokenCapCalculated(uint256 saleCap, uint256 numRegistered, uint256 cap, string Msg);
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);

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

  function registerUsers(address[] _registrants) returns (bool) {
    return sale.registerUsers(_registrants);
  }

  function unregisterUser(address _registrant) returns (bool) {
    return sale.unregisterUser(_registrant);
  }

  function unregisterUsers(address[] _registrants) returns (bool) {
    return sale.unregisterUser(_registrants);
  }

  function isRegistered(address _registrant) constant returns (bool) {
    return sale.isRegistered[_registrant];
  }

  function withdrawTokens() returns (bool) {
    return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
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
