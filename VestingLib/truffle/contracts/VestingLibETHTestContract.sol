pragma solidity ^0.4.15;

import "./VestingLib.sol";

contract VestingLibETHTestContract {
  using VestingLib for VestingLib.VestingStorage;

  VestingLib.VestingStorage public vesting;

  // Generic Error message, error code and string
  event LogErrorMsg(uint256 amount, string Msg);

  // Logs when a user is registered in the system for vesting
  event LogUserRegistered(address registrant);

  // Logs when a user is unregistered from the system
  event LogUserUnRegistered(address registrant);

  // Logs when a user replaces themselves with a different beneficiary
  event LogRegistrationReplaced(address currentRegistrant, address newRegistrant, uint256 amountWithdrawn);

  // Logs when a user withdraws their ETH from vesting
  event LogETHWithdrawn(address beneficiary, uint256 amount);

  function VestingLibETHTestContract(
                address _owner,
                bool _isToken,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _numReleases)
  {
    vesting.init(_owner, _isToken, _startTime, _endTime, _numReleases);
  }

  function() payable {}

  function initializeETHBalance() payable returns (bool) {
    return vesting.initializeETHBalance(msg.value);
  }

  function registerUser(address _registrant, uint256 _vestAmount, uint256 _bonus) returns (bool) {
    return vesting.registerUser(_registrant, _vestAmount, _bonus);
  }

  function registerUsers(address[] _registrants, uint256 _vestAmount, uint256 _bonus) returns (bool) {
    return vesting.registerUsers(_registrants, _vestAmount, _bonus);
  }

  function unregisterUser(address _registrant) returns (bool) {
    return vesting.unregisterUser(_registrant);
  }

  function unregisterUsers(address[] _registrants) returns (bool) {
    return vesting.unregisterUsers(_registrants);
  }

  function swapRegistration(address _replacementRegistrant) returns (bool) {
    return vesting.swapRegistration(_replacementRegistrant);
  }

  function withdrawETH() returns (bool) {
    return vesting.withdrawETH();
  }

  function sendETH(address _beneficiary) returns (bool) {
    return vesting.sendETH(_beneficiary);
  }

  function ownerWithdrawExtraETH() returns (bool) {
    return vesting.ownerWithdrawExtraETH();
  }

  /*Getters*/

  function getOwner() constant returns (address) {
    return vesting.owner;
  }

  function getTotalSupply() constant returns (uint256) {
    return vesting.totalSupply;
  }

  function getContractBalance() constant returns (uint256) {
    return vesting.contractBalance;
  }

  function getIsToken() constant returns (bool) {
    return vesting.isToken;
  }

  function getStartTime() constant returns (uint256) {
    return vesting.startTime;
  }

  function getEndTime() constant returns (uint256) {
    return vesting.endTime;
  }

  function getNumRegistered() constant returns (uint256) {
    return vesting.numRegistered;
  }

  function getTimeInterval() constant returns (uint256) {
    return vesting.timeInterval;
  }

  function getPercentPerInterval() constant returns (uint256) {
    return vesting.percentPerInterval;
  }

  function getPercentReleased() constant returns (uint256) {
    return vesting.getPercentReleased();
  }

  function getHasWithdrawn(address _participant) constant returns (uint256) {
    return vesting.hasWithdrawn[_participant];
  }

  function getVestingAmount(address _participant) constant returns (uint256) {
    return vesting.holdingAmount[_participant][0];
  }

  function getBonusAmount(address _participant) constant returns (uint256) {
    return vesting.holdingAmount[_participant][1];
  }
}
