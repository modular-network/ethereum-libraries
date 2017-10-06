pragma solidity ^0.4.15;

import "./WalletMainLib.sol";
import "./WalletAdminLib.sol";
import "./WalletGetterLib.sol";

contract WalletLibTestContract {
  using WalletMainLib for WalletMainLib.WalletData;
  using WalletAdminLib for WalletMainLib.WalletData;
  using WalletGetterLib for WalletMainLib.WalletData;

  WalletMainLib.WalletData public wallet;

  event Deposit(uint value);

  function WalletLibTestContract() {
    address[] memory _owners = new address[](5);
    _owners[0] = 0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623;
    _owners[1] = 0x40333d950b4c682e8aad143c216af52877d828bf;
    _owners[2] = 0x0a1f4fcde83ba12ee8343488964811218da3e00e;
    _owners[3] = 0x79b63228ff63659248b7c688870de388bdcf0c14;
    _owners[4] = 0x36994c7cff11859ba8b9715120a68aa9499329ee;
    wallet.init(_owners,4,3,1,100000000000000000000);
  }

  function() payable {
    Deposit(msg.value);
  }

  /*Getters*/

  function owners() constant returns (address[51]) {
    return wallet.getOwners();
  }

  function ownerIndex(address _owner) constant returns (uint) {
    return wallet.getOwnerIndex(_owner);
  }

  function maxOwners() constant returns (uint) {
    return wallet.getMaxOwners();
  }

  function ownerCount() constant returns (uint) {
    return wallet.getOwnerCount();
  }

  function requiredAdmin() constant returns (uint) {
    return wallet.getRequiredAdmin();
  }

  function requiredMinor() constant returns (uint) {
    return wallet.getRequiredMinor();
  }

  function requiredMajor() constant returns (uint) {
    return wallet.getRequiredMajor();
  }

  function currentSpend(address _token) constant returns (uint[2]) {
    return wallet.getCurrentSpend(_token);
  }

  function majorThreshold(address _token) constant returns (uint) {
    return wallet.getMajorThreshold(_token);
  }

  function transactions(uint _date) constant returns (bytes32[10]) {
    return wallet.getTransactions(_date);
  }

  function transactionLength(bytes32 _id) constant returns (uint) {
    return wallet.getTransactionLength(_id);
  }

  function transactionConfirms(bytes32 _id, uint _number) constant returns (uint256[50]) {
    return wallet.getTransactionConfirms(_id, _number);
  }

  function transactionConfirmCount(bytes32 _id, uint _number) constant returns (uint) {
    return wallet.getTransactionConfirmCount(_id, _number);
  }

  function transactionSuccess(bytes32 _id, uint _number) constant returns (bool){
    return wallet.getTransactionSuccess(_id, _number);
  }

  /*Changers*/

  function changeOwner(address _from, address _to, bool _confirm) returns (bool,bytes32) {
    return wallet.changeOwner(_from, _to, _confirm, msg.data);
  }

  function addOwner(address _newOwner, bool _confirm) returns (bool,bytes32) {
    return wallet.addOwner(_newOwner, _confirm, msg.data);
  }

  function removeOwner(address _ownerRemoving, bool _confirm) returns (bool,bytes32) {
    return wallet.removeOwner(_ownerRemoving, _confirm, msg.data);
  }

  function changeRequiredAdmin(uint _newRequired, bool _confirm) returns (bool,bytes32) {
    return wallet.changeRequiredAdmin(_newRequired, _confirm, msg.data);
  }

  function changeRequiredMajor(uint _newRequired, bool _confirm) returns (bool,bytes32) {
    return wallet.changeRequiredMajor(_newRequired, _confirm, msg.data);
  }

  function changeRequiredMinor(uint _newRequired, bool _confirm) returns (bool,bytes32) {
    return wallet.changeRequiredMinor(_newRequired, _confirm, msg.data);
  }

  function changeMajorThreshold(address _token, uint _newThreshold, bool _confirm) returns (bool,bytes32) {
    return wallet.changeMajorThreshold(_token, _newThreshold, _confirm, msg.data);
  }

  /*Tx Execution*/

  function serveTx(address _to, uint _value, bytes _txData, bool _confirm) returns (bool,bytes32) {
    return wallet.serveTx(_to, _value, _txData, _confirm, msg.data);
  }

  function confirmTx(bytes32 _id) returns (bool) {
    return wallet.confirmTx(_id);
  }

  function revokeConfirm(bytes32 _id) returns (bool) {
    return wallet.revokeConfirm(_id);
  }

  function checkNotConfirmed(bytes32 _id, uint _number) returns (bool) {
    return wallet.checkNotConfirmed(_id, _number);
  }
}
