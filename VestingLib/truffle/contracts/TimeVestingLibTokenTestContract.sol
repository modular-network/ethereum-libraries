pragma solidity ^0.4.15;

import "./TestVestingLib.sol";
import "./CrowdsaleToken.sol";

contract TimeVestingLibTokenTestContract {
  using TestVestingLib for TestVestingLib.TestVestingStorage;

  TestVestingLib.TestVestingStorage vesting;

  event Deposit(uint value);

  function TimeVestingLibTokenTestContract(
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

  function initializeTokenBalance(CrowdsaleToken token, uint256 _balance, uint256 _bonus) returns (bool) {
    return vesting.initializeTokenBalance(token, _balance, _bonus);
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

  function withdrawTokens(CrowdsaleToken token, uint256 _currtime) returns (bool) {
    return vesting.withdrawTokens(token, _currtime);
  }

  function ownerWithdrawExtraTokens(CrowdsaleToken token) returns (bool) {
    return vesting.ownerWithdrawExtraTokens(token);
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
