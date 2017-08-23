pragma solidity 0.4.13;

import "./Array256Lib.sol";
import "./BasicMathLib.sol";

library WalletLib {
  using Array256Lib for uint256[];
  using BasicMathLib for uint;

  struct WalletData {
    uint maxOwners; //Maximum wallet owners, should be 50
    address[] owners; //Array of all owners
    uint requiredAdmin; //Number of sigs required for administrative changes
    uint requiredMajor; //Number of sigs required for major transactions
    uint requiredMinor; //Number of sigs required for minor transactions
    //The amount of a token spent per day, ether is at address mapping 0, all other tokens defined by address
    // uint[0] corresponds to the current day,  uint[1] is the spend amount
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
  event LogOwnerAdded(address newOwner);
  event LogOwnerRemoved(address ownerRemoved);
  event LogOwnerChanged(address from, address to);
  event LogRequirementChange(uint newRequired);
  event LogThresholdChange(address token, uint newThreshold);
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

  /// @dev Validates arguments for changeOwner function
  /// @param _from Index of current owner removing
  /// @param _to Index of new potential owner, should be 0
  /// @return Returns true if check passes, false otherwise
  function checkChangeOwnerArgs(uint _from, uint _to) constant returns (bool) {
    if(_from == 0){
      LogErrMsg("Change from address is not an owner");
      return false;
    }
    if(_to != 0){
      LogErrMsg("Change to address is an owner");
      return false;
    }
    return true;
  }

  /// @dev Validates arguments for addOwner function
  /// @param _index Index of new owner, should be 0
  /// @param _length Current length of owner array
  /// @return Returns true if check passes, false otherwise
  function checkNewOwnerArgs(uint _index, uint _length, uint _max)
           constant returns (bool)
  {
    if(_index != 0){
      LogErrMsg("New owner already owner");
      return false;
    }
    if((_length + 1) > _max){
      LogErrMsg("Too many owners");
      return false;
    }
    return true;
  }

  /// @dev Validates arguments for removeOwner function
  /// @param _index Index of owner removing
  /// @param _length Current number of owners
  /// @param _min Minimum owners currently required to meet sig requirements
  /// @return Returs true if check passes, false otherwise
  function checkRemoveOwnerArgs(uint _index, uint _length, uint _min)
           constant returns (bool)
  {
    if(_index == 0){
      LogErrMsg("Owner removing not an owner");
      return false;
    }
    if(_length - 1 < _min){
      LogErrMsg("Must reduce requiredAdmin first");
      return false;
    }
    return true;
  }

  /// @dev Validates arguments for changing any of the sig requirement parameters
  /// @param _newRequired The new sig requirement
  /// @param _length Current number of owners
  /// @return Returns true if checks pass, false otherwise
  function checkRequiredChange(uint _newRequired, uint _length)
           constant returns (bool)
  {
    if(_newRequired == 0){
      LogErrMsg("Cant reduce to 0");
      return false;
    }
    if(_length - 1 < _newRequired){
      LogErrMsg("Making requirement too high");
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

  /*Confirm/Revoke functions using tx ID*/

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

  /*Administrative Functions*/

  /// @dev Changes owner address to a new address
  /// @param self Wallet in contract storage
  /// @param _from Current owner address
  /// @param _to New address
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function changeOwner(WalletData storage self,
                       address _from,
                       address _to,
                       bool _confirm,
                       bytes _data)
                       returns (bool,bytes32)
  {
    bytes32 _id = sha3("changeOwner",_from,_to);
    uint _number = self.transactionInfo[_id].length;
    bool allGood;

    //Run checks if not called from generic confirm/revoke function
    if(msg.sender != address(this)){
      if(!_confirm) {                             //if the owner is revoking his confirmation of this administrative change but doesn't know the specific transaction id hash
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {  //confirming the change
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){    //if this is a new transaction or if a previous identical transaction had already succeeded 
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkChangeOwnerArgs(self.ownerIndex[_from], self.ownerIndex[_to]);
          if(!allGood)
            return (false,0);
          //  add this transaction to the wallets record and initialize the settings
          self.transactionInfo[_id].length++;   
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {  // if the transaction already exists
          _number--;      //set the index to the index of the existing transaction
          allGood = checkNotConfirmed(self, _id, _number);   //make sure the sender isn't already confirmed
          if(!allGood)
            return (false,_id);
        }
      }
      // add the senders confirmation to the change
      self.transactionInfo[_id][_number].confirmedOwners.push(uint256(msg.sender));    
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;   // set the _number index to the index of the existing transaction
    }

    // if there are enough admin confirmations
    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      // execute the owner change transaction
      uint i = self.ownerIndex[_from];
      self.ownerIndex[_from] = 0;
      self.owners[i] = _to;
      self.ownerIndex[_to] = i;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogOwnerChanged(_from, _to);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);

      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Adds owner to wallet
  /// @param self Wallet in contract storage
  /// @param _newOwner Address for new owner
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function addOwner(WalletData storage self,
                    address _newOwner,
                    bool _confirm,
                    bytes _data)
                    returns (bool,bytes32)
  {
    bytes32 _id = sha3("addOwner",_newOwner);
    uint _number = self.transactionInfo[_id].length;
    bool allGood;

    if(msg.sender != address(this)){
      require(_newOwner != 0);

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkNewOwnerArgs(self.ownerIndex[_newOwner],
                                      self.owners.length,
                                      self.maxOwners);
          if(!allGood)
            return (false,0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.owners.push(_newOwner);
      self.ownerIndex[_newOwner] = self.owners.length - 1;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogOwnerAdded(_newOwner);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Removes owner from wallet
  /// @param self Wallet in contract storage
  /// @param _ownerRemoving Address of owner to be removed
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function removeOwner(WalletData storage self,
                       address _ownerRemoving,
                       bool _confirm,
                       bytes _data)
                       returns (bool,bytes32)
  {
    bytes32 _id = sha3("removeOwner",_ownerRemoving);
    uint _number = self.transactionInfo[_id].length;
    bool allGood;

    if(msg.sender != address(this)){
      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkRemoveOwnerArgs(self.ownerIndex[_ownerRemoving],
                                         self.owners.length,
                                         self.requiredAdmin);
          if(!allGood)
            return (false,0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.owners[self.ownerIndex[_ownerRemoving]] = self.owners[self.owners.length - 1];
      self.ownerIndex[self.owners[self.owners.length - 1]] = self.ownerIndex[_ownerRemoving];
      self.ownerIndex[_ownerRemoving] = 0;
      self.owners.length--;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogOwnerRemoved(_ownerRemoving);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Changes required sigs to change wallet parameters
  /// @param self Wallet in contract storage
  /// @param _requiredAdmin The new signature requirement
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function changeRequiredAdmin(WalletData storage self,
                               uint _requiredAdmin,
                               bool _confirm,
                               bytes _data)
                               returns (bool,bytes32)
  {
    bytes32 _id = sha3("changeRequiredAdmin",_requiredAdmin);
    uint _number = self.transactionInfo[_id].length;

    if(msg.sender != address(this)){
      bool allGood;

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkRequiredChange(_requiredAdmin, self.owners.length);
          if(!allGood)
            return (false,0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
      self.transactionInfo[_id][_number].confirmRequired)
    {
      self.requiredAdmin = _requiredAdmin;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogRequirementChange(_requiredAdmin);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Changes required sigs for major transactions
  /// @param self Wallet in contract storage
  /// @param _requiredMajor The new signature requirement
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function changeRequiredMajor(WalletData storage self,
                               uint _requiredMajor,
                               bool _confirm,
                               bytes _data)
                               returns (bool,bytes32)
  {
    bytes32 _id = sha3("changeRequiredMajor",_requiredMajor);
    uint _number = self.transactionInfo[_id].length;

    if(msg.sender != address(this)){
      bool allGood;

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkRequiredChange(_requiredMajor, self.owners.length);
          if(!allGood)
            return (false,0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.requiredMajor = _requiredMajor;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogRequirementChange(_requiredMajor);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Changes required sigs for minor transactions
  /// @param self Wallet in contract storage
  /// @param _requiredMinor The new signature requirement
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function changeRequiredMinor(WalletData storage self,
                               uint _requiredMinor,
                               bool _confirm,
                               bytes _data)
                               returns (bool,bytes32)
  {
    bytes32 _id = sha3("changeRequiredMinor",_requiredMinor);
    uint _number = self.transactionInfo[_id].length;

    if(msg.sender != address(this)){
      bool allGood;

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);
          allGood = checkRequiredChange(_requiredMinor, self.owners.length);
          if(!allGood)
            return (false,0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.requiredMinor = _requiredMinor;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogRequirementChange(_requiredMinor);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

  /// @dev Changes threshold for major transaction day spend per token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, ether is 0
  /// @param _majorThreshold New threshold
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function changeMajorThreshold(WalletData storage self,
                                address _token,
                                uint _majorThreshold,
                                bool _confirm,
                                bytes _data)
                                returns (bool,bytes32)
  {
    bytes32 _id = sha3("changeMajorThreshold", _token, _majorThreshold);
    uint _number = self.transactionInfo[_id].length;

    if(msg.sender != address(this)){
      bool allGood;

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = self.requiredAdmin;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    } else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.majorThreshold[_token] = _majorThreshold;
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
      LogThresholdChange(_token, _majorThreshold);
    } else {
      if(self.transactionInfo[_id][_number].data.length == 0)
        self.transactionInfo[_id][_number].data = _data;

      uint confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_number].confirmRequired,
                                               self.transactionInfo[_id][_number].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
	}

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

    if(msg.sender != address(this)){
      bool allGood;
      uint _amount;

      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else {
        if(_number == 0 || self.transactionInfo[_id][_number - 1].success){
          require(self.ownerIndex[msg.sender] > 0);

          //Reuse allGood due to stack limit
          if(_to != 0)
            (allGood,_amount) = getAmount(_txData);

          _required = getRequired(self, _to, _value, allGood,_amount);
          if(_required == 0)
            return (false, _id);

          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_number].confirmRequired = _required;
          self.transactionInfo[_id][_number].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else {
          _number--;
          allGood = checkNotConfirmed(self, _id, _number);
          if(!allGood)
            return (false,_id);
        }
      }

      self.transactionInfo[_id][_number].confirmedOwners.push(uint(msg.sender));
      self.transactionInfo[_id][_number].confirmCount++;
    }else {
      _number--;
    }

    if(self.transactionInfo[_id][_number].confirmCount ==
       self.transactionInfo[_id][_number].confirmRequired)
    {
      self.currentSpend[0][1] += _value;
      self.currentSpend[_to][1] += _amount;

      if(_to == 0){
        //Failure is self contained in method
    		createContract(_txData, _value);
      } else {
        require(_to.call.value(_value)(_txData));
      }
      delete self.transactionInfo[_id][_number].data;
      self.transactionInfo[_id][_number].success = true;
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

  /*Getter Functions*/

  /// @dev Get list of wallet owners, will return fixed 50 until fork
  /// @param self Wallet in contract storage
  /// @return address[51] Returns entire 51 owner slots
  function getOwners(WalletData storage self) constant returns (address[51]) {
    address[51] memory o;
    for(uint i = 0; i<self.owners.length; i++){
      o[i] = self.owners[i];
    }
    return o;
  }

  /// @dev Get index of an owner
  /// @param self Wallet in contract storage
  /// @param _owner Address of owner
  /// @return uint Index of the owner
  function getOwnerIndex(WalletData storage self, address _owner) constant returns (uint) {
    return self.ownerIndex[_owner];
  }

  /// @dev Get max number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint Maximum number of owners
  function getMaxOwners(WalletData storage self) constant returns (uint) {
    return self.maxOwners;
  }

  /// @dev Get number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint Number of owners
  function getOwnerCount(WalletData storage self) constant returns (uint) {
    return self.owners.length - 1;
  }

  /// @dev Get sig requirements for administrative changes
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredAdmin(WalletData storage self) constant returns (uint) {
    return self.requiredAdmin;
  }

  /// @dev Get sig requirements for minor tx spends
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredMinor(WalletData storage self) constant returns (uint) {
    return self.requiredMinor;
  }

  /// @dev Get sig requirements for major tx spends
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredMajor(WalletData storage self) constant returns (uint) {
    return self.requiredMajor;
  }

  /// @dev Get current day spend for token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint[2] 0-index is day timestamp, 1-index is the day spend
  function getCurrentSpend(WalletData storage self, address _token) constant returns (uint[2]) {
    uint[2] memory cs;
    cs[0] = self.currentSpend[_token][0];
    cs[1] = self.currentSpend[_token][1];
    return cs;
  }

  /// @dev Get major tx threshold per token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint Threshold amount
  function getMajorThreshold(WalletData storage self, address _token) constant returns (uint) {
    return self.majorThreshold[_token];
  }

  /// @dev Get last 10 transactions for the day, fixed at 10 until fork
  /// @param self Wallet in contract storage
  /// @param _date Timestamp of day requested
  /// @return bytes32[10] Last 10 tx's starting with latest
  function getTransactions(WalletData storage self, uint _date) constant returns (bytes32[10]) {
    bytes32[10] memory t;
    uint li = self.transactions[_date].length - 1;
    for(uint i = li; i >= 0; i--){
      t[li - i] = self.transactions[_date][i];
    }
    return t;
  }

  /// @dev Get the number of tx's with the same id
  /// @param self Wallet in contract storage
  /// @param _id ID of transactions requested
  /// @return uint Number of tx's with same ID
  function getTransactionLength(WalletData storage self, bytes32 _id) constant returns (uint) {
    return self.transactionInfo[_id].length;
  }

  /// @dev Get list of confirmations for a tx, use getTransactionLength to get latest number
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _number The transaction index number
  /// @return uint256[50] Returns list of confirmations, fixed at 50 until fork
  function getTransactionConfirms(WalletData storage self,
                                  bytes32 _id,
                                  uint _number)
                                  constant returns (uint256[50])
  {
    uint256[50] memory tc;
    for(uint i = 0; i<self.transactionInfo[_id][_number].confirmedOwners.length; i++){
      tc[i] = self.transactionInfo[_id][_number].confirmedOwners[i];
    }
    return tc;
  }

  /// @dev Retrieve tx confirmation count
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _number The transaction index number
  /// @return uint Returns the current number of tx confirmations
  function getTransactionConfirmCount(WalletData storage self,
                           bytes32 _id,
                           uint _number)
                           constant returns(uint)
  {
    return self.transactionInfo[_id][_number].confirmCount;
  }

  /// @dev Retrieve if transaction was successful
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _number The transaction index number
  /// @return bool Returns true if tx successfully executed, false otherwise
  function getTransactionSuccess(WalletData storage self,
                                 bytes32 _id,
                                 uint _number)
                                 constant returns (bool)
  {
    return self.transactionInfo[_id][_number].success;
  }
}
