pragma solidity ^0.4.15;

import "./TestVestingLib.sol";

contract TimeVestingLibETHTestContract {
  using TestVestingLib for TestVestingLib.TestVestingStorage;

  TestVestingLib.TestVestingStorage vesting;

  event Deposit(uint value);

  function TimeVestingLibETHTestContract(
                address _owner,
                bool _isToken,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _numReleases) 
  {
    vesting.init(_owner, _isToken, _startTime, _endTime, _numReleases);
  }

  function() payable {
    
  }

  function initializeETHBalance(uint256 _balance, uint256 _bonus) payable returns (bool) {
    return vesting.initializeETHBalance(_balance, _bonus);
  }

  function registerUser(address _registrant) returns (bool) {
    return vesting.registerUser(_registrant);
  }

  function registerUsers(address[] _registrants) returns (bool) {
    return vesting.registerUsers(_registrants);
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

  function withdrawETH(uint256 _currtime) returns (bool) {
    return vesting.withdrawETH(_currtime);
  }

  function sendETH(address _beneficiary, uint256 _currtime) returns (bool) {
    return vesting.sendETH(_beneficiary,_currtime);
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

  function getBonus() constant returns (uint256) {
    return vesting.bonus;
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

  function getPercentReleased() constant returns (uint256) {
    return vesting.percentReleased;
  }

  function getIsRegistered(address _participant) constant returns (bool) {
    return vesting.getisRegistered(_participant);
  }

  function getHasWithdrawn(address _participant) constant returns (uint256) {
    return vesting.gethasWithdrawn(_participant);
  }








}
