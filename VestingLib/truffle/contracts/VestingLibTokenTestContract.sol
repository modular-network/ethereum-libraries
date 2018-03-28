pragma solidity ^0.4.18;

import "./VestingLib.sol";
import "./CrowdsaleToken.sol";

contract VestingLibTokenTestContract {
  using VestingLib for VestingLib.VestingStorage;

  VestingLib.VestingStorage public vesting;

  function VestingLibTokenTestContract(
                address _owner,
                bool _isToken,
                uint256 _startTime,
                uint256 _endTime,
                uint256 _numReleases) public
  {
    vesting.init(_owner, _isToken, _startTime, _endTime, _numReleases);
  }

  // Generic Error message, error code and string
  event LogErrorMsg(uint256 amount, string Msg);

  // Logs when a user is registered in the system for vesting
  event LogUserRegistered(address registrant, uint256 vestAmount, uint256 bonus);

  // Logs when a user is unregistered from the system
  event LogUserUnRegistered(address registrant);

  // Logs when a user replaces themselves with a different beneficiary
  event LogRegistrationReplaced(address currentRegistrant, address newRegistrant, uint256 amountWithdrawn);

  // Logs when a user withdraws their tokens from the contract
  event LogTokensWithdrawn(address beneficiary, uint256 amount);

  function() payable public {}

  function initializeTokenBalance(CrowdsaleToken token, uint256 _balance) public returns (bool) {
    return vesting.initializeTokenBalance(token, _balance);
  }

  function registerUser(address _registrant, uint256 _vestAmount, uint256 _bonus) public returns (bool) {
    return vesting.registerUser(_registrant, _vestAmount, _bonus);
  }

  function registerUsers(address[] _registrants, uint256 _vestAmount, uint256 _bonus) public returns (bool) {
    return vesting.registerUsers(_registrants, _vestAmount, _bonus);
  }

  function unregisterUser(address _registrant) public returns (bool) {
    return vesting.unregisterUser(_registrant);
  }

  function unregisterUsers(address[] _registrants) public returns (bool) {
    return vesting.unregisterUsers(_registrants);
  }

  function swapRegistration(address _replacementRegistrant) public returns (bool) {
    return vesting.swapRegistration(_replacementRegistrant);
  }

  function withdrawTokens(CrowdsaleToken token) public returns (bool) {
    return vesting.withdrawTokens(token);
  }

  function sendTokens(CrowdsaleToken token, address _beneficiary) public returns (bool) {
    return vesting.sendTokens(token,_beneficiary);
  }

  function ownerWithdrawExtraTokens(CrowdsaleToken token) public returns (bool) {
    return vesting.ownerWithdrawExtraTokens(token);
  }

  /*Getters*/

  function getOwner() public view returns (address) {
    return vesting.owner;
  }

  function getTotalSupply() public view returns (uint256) {
    return vesting.totalSupply;
  }

  function getContractBalance() public view returns (uint256) {
    return vesting.contractBalance;
  }

  function getIsToken() public view returns (bool) {
    return vesting.isToken;
  }

  function getStartTime() public view returns (uint256) {
    return vesting.startTime;
  }

  function getEndTime() public view returns (uint256) {
    return vesting.endTime;
  }

  function getNumRegistered() public view returns (uint256) {
    return vesting.numRegistered;
  }

  function getTimeInterval() public view returns (uint256) {
    return vesting.timeInterval;
  }

  function getPercentPerInterval() public view returns (uint256) {
    return vesting.percentPerInterval;
  }

  function getPercentReleased() public view returns (uint256) {
    return vesting.getPercentReleased();
  }

  function getHasWithdrawn(address _participant) public view returns (uint256) {
    return vesting.hasWithdrawn[_participant];
  }

  function getVestingAmount(address _participant) public view returns (uint256) {
    return vesting.holdingAmount[_participant][0];
  }

  function getBonusAmount(address _participant) public view returns (uint256) {
    return vesting.holdingAmount[_participant][1];
  }

}
