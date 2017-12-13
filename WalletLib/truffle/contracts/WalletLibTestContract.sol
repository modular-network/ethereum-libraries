pragma solidity ^0.4.18;

import "./WalletMainLib.sol";
import "./WalletAdminLib.sol";
import "./WalletGetterLib.sol";

contract WalletLibTestContract {
  using WalletMainLib for WalletMainLib.WalletData;
  using WalletAdminLib for WalletMainLib.WalletData;
  using WalletGetterLib for WalletMainLib.WalletData;

  WalletMainLib.WalletData public wallet;

  event LogDeposit(uint256 value);

  /*Events*/
  event LogTransactionConfirmed(bytes32 txid, address sender, uint256 confirmsNeeded);
  event LogOwnerAdded(address newOwner);
  event LogOwnerRemoved(address ownerRemoved);
  event LogOwnerChanged(address from, address to);
  event LogRequirementChange(uint256 newRequired);
  event LogThresholdChange(address token, uint256 newThreshold);
  event LogErrorMsg(uint256 amount, string msg);
  event LogRevokeNotice(bytes32 txid, address sender, uint256 confirmsNeeded);
  event LogTransactionFailed(bytes32 txid, address sender);
  event LogTransactionComplete(bytes32 txid, address target, uint256 value, bytes data);
  event LogContractCreated(address newContract, uint256 value);

  function WalletLibTestContract() public {
    address[] memory _owners = new address[](5);
    _owners[0] = 0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623;
    _owners[1] = 0x40333d950b4c682e8aad143c216af52877d828bf;
    _owners[2] = 0x0a1f4fcde83ba12ee8343488964811218da3e00e;
    _owners[3] = 0x79b63228ff63659248b7c688870de388bdcf0c14;
    _owners[4] = 0x36994c7cff11859ba8b9715120a68aa9499329ee;
    wallet.init(_owners,4,3,1,100000000000000000000);
  }

  function() public payable {
    LogDeposit(msg.value);
  }

  /*Getters*/

  function owners() public view returns (address[51]) {
    return wallet.getOwners();
  }

  function ownerIndex(address _owner) public view returns (uint256) {
    return wallet.getOwnerIndex(_owner);
  }

  function maxOwners() public view returns (uint256) {
    return wallet.getMaxOwners();
  }

  function ownerCount() public view returns (uint256) {
    return wallet.getOwnerCount();
  }

  function requiredAdmin() public view returns (uint256) {
    return wallet.getRequiredAdmin();
  }

  function requiredMinor() public view returns (uint256) {
    return wallet.getRequiredMinor();
  }

  function requiredMajor() public view returns (uint256) {
    return wallet.getRequiredMajor();
  }

  function currentSpend(address _token) public view returns (uint256[2]) {
    return wallet.getCurrentSpend(_token);
  }

  function majorThreshold(address _token) public view returns (uint256) {
    return wallet.getMajorThreshold(_token);
  }

  function transactionLength(bytes32 _id) public view returns (uint256) {
    return wallet.getTransactionLength(_id);
  }

  function transactionConfirms(bytes32 _id, uint256 _txIndex) public view returns (uint256[50]) {
    return wallet.getTransactionConfirms(_id, _txIndex);
  }

  function transactionConfirmCount(bytes32 _id, uint256 _txIndex) public view returns (uint256) {
    return wallet.getTransactionConfirmCount(_id, _txIndex);
  }

  function transactionSuccess(bytes32 _id, uint256 _txIndex) public view returns (bool){
    return wallet.getTransactionSuccess(_id, _txIndex);
  }

  /*Changers*/

  function changeOwner(address _from, address _to, bool _confirm) public returns (bool,bytes32) {
    return wallet.changeOwner(_from, _to, _confirm, msg.data);
  }

  function addOwner(address _newOwner, bool _confirm) public returns (bool,bytes32) {
    return wallet.addOwner(_newOwner, _confirm, msg.data);
  }

  function removeOwner(address _ownerRemoving, bool _confirm) public returns (bool,bytes32) {
    return wallet.removeOwner(_ownerRemoving, _confirm, msg.data);
  }

  function changeRequiredAdmin(uint256 _newRequired, bool _confirm) public returns (bool,bytes32) {
    return wallet.changeRequiredAdmin(_newRequired, _confirm, msg.data);
  }

  function changeRequiredMajor(uint256 _newRequired, bool _confirm) public returns (bool,bytes32) {
    return wallet.changeRequiredMajor(_newRequired, _confirm, msg.data);
  }

  function changeRequiredMinor(uint256 _newRequired, bool _confirm) public returns (bool,bytes32) {
    return wallet.changeRequiredMinor(_newRequired, _confirm, msg.data);
  }

  function changeMajorThreshold(address _token, uint256 _newThreshold, bool _confirm) public returns (bool,bytes32) {
    return wallet.changeMajorThreshold(_token, _newThreshold, _confirm, msg.data);
  }

  /*Tx Execution*/

  function serveTx(address _to, uint256 _value, bytes _txData, bool _confirm) public returns (bool,bytes32) {
    return wallet.serveTx(_to, _value, _txData, _confirm, msg.data);
  }

  function confirmTx(bytes32 _id) public returns (bool) {
    return wallet.confirmTx(_id);
  }

  function revokeConfirm(bytes32 _id) public returns (bool) {
    return wallet.revokeConfirm(_id);
  }

  function checkNotConfirmed(bytes32 _id, uint256 _txIndex) public returns (bool) {
    return wallet.checkNotConfirmed(_id, _txIndex);
  }
}
