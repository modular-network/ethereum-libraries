pragma solidity ^0.4.13;

/**
 * @title Wallet Main Library
 * @author Majoolr.io
 *
 * version 1.0.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Wallet Library family is inspired by the multisig wallets built by Consensys
 * at https://github.com/ConsenSys/MultiSigWallet and Parity at
 * https://github.com/paritytech/contracts/blob/master/Wallet.sol with added
 * functionality. Majoolr works on open source projects in the Ethereum
 * community with the purpose of testing, documenting, and deploying reusable
 * code onto the blockchain to improve security and usability of smart contracts.
 * Majoolr also strives to educate non-profits, schools, and other community
 * members about the application of blockchain technology. For further
 * information: majoolr.io, consensys.net, paritytech.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import "./Array256Lib.sol";
import "./BasicMathLib.sol";

library WalletMainLib {
  using Array256Lib for uint256[];
  using BasicMathLib for uint;

  struct WalletData {
    uint maxOwners; //Maximum wallet owners, should be 50
    address[] owners; //Array of all owners
    uint requiredAdmin; //Number of sigs required for administrative changes
    uint requiredMajor; //Number of sigs required for major transactions
    uint requiredMinor; //Number of sigs required for minor transactions

    // The amount of a token spent per day, ether is at address mapping 0,
    // all other tokens defined by address. uint[0] corresponds to the current
    // day,  uint[1] is the spend amount
    mapping (address => uint[2]) currentSpend;
    //The day spend threshold for transactions to be major, ether at 0, all others by address
    mapping (address => uint) majorThreshold;
    //Array of transactions per day, uint is the day timestamp, bytes32 is the transaction id
    mapping (uint => bytes32[]) transactions;
    //Tracks the index of each owner in the owners Array
    mapping (address => uint) ownerIndex;
    //Array of Transaction's by id, new tx's with exact inputs as previous tx will add to array
    mapping (bytes32 => Transaction[]) transactionInfo;

  }

  struct Transaction {
    uint day; //Timestamp of the day initialized
    uint value; //Amount of ether being sent
    address tokenAdress; //Address of token transferred
    uint amount; //Amount of tokens transferred
    bytes data; //Temp location for pending transactions, erased after final confirmation
    uint256[] confirmedOwners; //Array of owners confirming transaction
    uint confirmCount; //Tracks the number of confirms
    uint confirmRequired; //Number of sigs required for this transaction
    bool success; //True after final confirmation
  }

  /*Events*/
  event LogRevokeNotice(bytes32 txid, address sender, uint confirmsNeeded);
  event LogTransactionFailed(bytes32 txid, address sender);
  event LogTransactionConfirmed(bytes32 txid, address sender, uint confirmsNeeded);
  event LogTransactionComplete(bytes32 txid, address target, uint value, bytes data);
  event LogContractCreated(address newContract, uint value);
  event LogErrMsg(string msg);

  /// @dev Constructor
  /// @param self The wallet in contract storage
  /// @param _owners Array of initial owners
  /// @param _requiredAdmin Set number of sigs for administrative tasks
  /// @param _requiredMajor Set number of sigs for major tx
  /// @param _requiredMinor Set number of sigs for minor tx
  /// @param _majorThreshold Set major tx threshold amount for ether
  /// @return Will return true when complete
  function init(WalletData storage self,
                address[] _owners,
                uint _requiredAdmin,
                uint _requiredMajor,
                uint _requiredMinor,
                uint _majorThreshold) returns (bool)
  {
    require(self.owners.length == 0);
    require(_owners.length >= _requiredAdmin && _requiredAdmin > 0);
    require(_owners.length >= _requiredMajor && _requiredMajor > 0);
    require(_owners.length >= _requiredMinor && _requiredMinor > 0);
    self.owners.push(0); //Leave index-0 empty for easier owner checks

    for (uint i=0; i<_owners.length; i++) {
      require(_owners[i] != 0);
      self.owners.push(_owners[i]);
      self.ownerIndex[_owners[i]] = i+1;
    }
    self.requiredAdmin = _requiredAdmin;
    self.requiredMajor = _requiredMajor;
    self.requiredMinor = _requiredMinor;
    self.maxOwners = 50; //Limits to 50 owners, should create wallet pools for more owners
    self.majorThreshold[0] = _majorThreshold; //Sets ether threshold at address 0

    return true;
  }

  /*Checks*/

  /// @dev Verifies a confirming owner has not confirmed already
  /// @param self Contract wallet in storage
  /// @param _id ID of the tx being checked
  /// @param _number Index number of this tx
  /// @return Returns true if check passes, false otherwise
  function checkNotConfirmed(WalletData storage self, bytes32 _id, uint _number)
           constant returns (bool)
  {
    require(self.ownerIndex[msg.sender] > 0);
    uint _txLen = self.transactionInfo[_id].length;

    if(_txLen == 0 || _number >= _txLen){
      LogErrMsg("Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    if(self.transactionInfo[_id][_number].success){
      LogErrMsg("Transaction already complete");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    //Function from Majoolr.io array utility library
    bool found;
    uint index;
    (found, index) = self.transactionInfo[_id][_number].confirmedOwners.indexOf(uint(msg.sender), false);
    if(found){
      LogErrMsg("Owner already confirmed");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    return true;
  }

  /*Utility Functions*/

  /// @dev Used later to calculate the number of confirmations needed for tx
  /// @param _required Number of sigs required
  /// @param _count Current number of sigs
  function calcConfirmsNeeded(uint _required, uint _count) constant returns (uint){
    return _required - _count;
  }

  /// @dev Used to check if tx is moving tokens and parses amount
  /// @param _txData Data for proposed tx
  /// @return bool True if transaction is moving tokens
  /// @return uint Amount of tokens involved, 0 if not spending tx
  function getAmount(bytes _txData) constant returns (bool,uint) {
    bytes32 getSig;
    bytes4 sig;
    bytes4 tSig = 0xa9059cbb; //transfer func signature
    bytes4 aSig = 0x095ea7b3; //approve func signature
    bytes4 tfSig = 0x23b872dd; //transferFrom func signature
    bool transfer;
    bytes32 _amountData;
    uint _amount;

    assembly { getSig := mload(add(_txData,0x20)) }
    sig = bytes4(getSig);
    if(sig ==  tSig || sig == aSig){
      transfer = true;
      assembly { _amountData := mload(add(_txData,0x44)) }
      _amount = uint(_amountData);
    } else if(sig == tfSig){
      transfer = true;
      assembly { _amountData := mload(add(_txData,0x64)) }
      _amount = uint(_amountData);
    }
    return (transfer,_amount);
  }

  /// @dev Retrieves sig requirement for spending tx
  /// @param self Contract wallet in storage
  /// @param _to Target address of transaction
  /// @param _value Amount of ether spend
  /// @param _isTransfer True if transferring other tokens, false otherwise
  /// @param _amount Amount of tokens being transferred, 0 if not a transfer tx
  /// @return uint The required sigs for tx
  function getRequired(WalletData storage self,
                       address _to,
                       uint _value,
                       bool _isTransfer,
                       uint _amount)
                       returns (uint)
  {
    bool err;
    uint res;
    bool major = true;
    //Reset spend if this is first check of the day
    if((now/ 1 days) > self.currentSpend[0][0]){
      self.currentSpend[0][0] = now / 1 days;
      self.currentSpend[0][1] = 0;
    }

    (err, res) = self.currentSpend[0][1].plus(_value);
    if(err){
      LogErrMsg("Overflow eth spend");
      return 0;
    }

    if(res < self.majorThreshold[0])
      major = false;

    if(_to != 0 && _isTransfer){
      if((now / 1 days) > self.currentSpend[_to][0]){
        self.currentSpend[_to][0] = now / 1 days;
        self.currentSpend[_to][1] = 0;
      }

      (err, res) = self.currentSpend[_to][1].plus(_amount);
      if(err){
        LogErrMsg("Overflow token spend");
        return 0;
      }
      if(res >= self.majorThreshold[_to])
        major = true;
    }

    return major ? self.requiredMajor : self.requiredMinor;
  }

  /// @dev Function to create new contract
  /// @param _txData Transaction data
  /// @param _value Amount of eth sending to new contract
  function createContract(bytes _txData, uint _value) {
    address _newContract;
    bool allGood;

    assembly {
      _newContract := create(_value, add(_txData, 0x20), mload(_txData))
      allGood := gt(extcodesize(_newContract),0)
    }
    require(allGood);
    LogContractCreated(_newContract, _value);
  }

  /*Primary Function*/

  /// @dev Create and execute transaction from wallet
  /// @param self Wallet in contract storage
  /// @param _to Address of target
  /// @param _value Amount of ether sending
  /// @param _txData Data for executing transaction
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function serveTx(WalletData storage self,
                   address _to,
                   uint _value,
                   bytes _txData,
                   bool _confirm,
                   bytes _data)
                   returns (bool,bytes32)
  {
    bytes32 _id = sha3("serveTx",_to,_value,_txData);
    uint _number = self.transactionInfo[_id].length;
    uint _required = self.requiredMajor;

    //Run checks if not called from generic confirm/revoke function
    if(msg.sender != address(this)){
      bool allGood;
      uint _amount;
      // if the owner is revoking his/her confirmation but doesn't know the
      // specific transaction id hash
      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else { // else confirming the transaction
        //if this is a new transaction id or if a previous identical transaction had already succeeded
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);

          //Reuse allGood due to stack limit
          if(_to != 0)
            (allGood,_amount) = getAmount(_txData);

          _required = getRequired(self, _to, _value, allGood,_amount);
          if(_required == 0)
            return (false, _id);

          // add this transaction to the wallets record and initialize the settings
          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = _required;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else { // else the transaction is already pending
          _number--; // set the index to the index of the existing transaction
          //make sure the sender isn't already confirmed
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      // add the senders confirmation to the transaction
      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    }else {
      // else were calling from generic confirm/revoke function, set the
      // _number index to the index of the existing transaction
      _number--;
    }

    // if there are enough confirmations
    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      // execute the transaction
      self.currentSpend[0][1] += _value;
      self.currentSpend[_to][1] += _amount;
      self.transactionInfo[_id][_number].success = true;

      if(_to == 0){
        //Failure is self contained in method
        createContract(_txData, _value);
      } else {
        require(_to.call.value(_value)(_txData));
      }
      delete self.transactionInfo[_id][_number].data;
      LogTransactionComplete(_id, _to, _value, _data);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
  }

  /*Confirm/Revoke functions using tx ID*/

  /// @dev Confirms a current pending tx, will execute if final confirmation
  /// @param self Wallet in contract storage
  /// @param _id ID of the transaction
  /// @return Returns true if successful, false otherwise
  function confirmTx(WalletData storage self, bytes32 _id) returns (bool){
    require(self.ownerIndex[msg.sender] > 0);
    uint _number = self.transactionInfo[_id].length;
    bool ret;

    if(_number == 0){
      LogErrMsg("Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    _number--;
    bool allGood = checkNotConfirmed(self, _id, _number);
    if(!allGood)
      return false;

    self.transactionInfo[_id][_number].confirmedOwners.push(uint256(msg.sender));
    self.transactionInfo[_id][_number].confirmCount++;

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      address a = address(this);
      require(a.call(self.transactionInfo[_id][_number].data));
    } else {
      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);

      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
      ret = true;
    }

    return ret;
  }

  /// @dev Revokes a prior confirmation from sender, call with tx ID
  /// @param self Wallet in contract storage
  /// @param _id ID of the transaction
  /// @return Returns true if successful, false otherwise
  function revokeConfirm(WalletData storage self, bytes32 _id)
           returns (bool)
  {
    require(self.ownerIndex[msg.sender] > 0);
    uint _number = self.transactionInfo[_id].length;

    if(_number == 0){
      LogErrMsg("Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    _number--;
    if(self.transactionInfo[_id][_number].success){
      LogErrMsg("Transaction already complete");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    //Function from Majoolr.io array utility library
    bool found;
    uint index;
    (found, index) = self.transactionInfo[_id][_number].confirmedOwners.indexOf(uint(msg.sender), false);
    if(!found){
      LogErrMsg("Owner has not confirmed tx");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }
    self.transactionInfo[_id][_number].confirmedOwners[index] = 0;
    self.transactionInfo[_id][_number].confirmCount--;

    uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                             self.transactionInfo[_id][_number].confirmCount);
    //Transaction removed if all sigs revoked but id remains in wallet transaction list
    if(self.transactionInfo[_id][_number].confirmCount == 0)
      self.transactionInfo[_id].length--;

    LogRevokeNotice(_id, msg.sender, confirmsNeeded);
    return true;
  }
}
