pragma solidity 0.4.13;

/**
 * @title Wallet Getter Library
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

import "./WalletMainLib.sol";

library WalletGetterLib {

  /*Getter Functions*/

  /// @dev Get list of wallet owners, will return fixed 50 until fork
  /// @param self Wallet in contract storage
  /// @return address[51] Returns entire 51 owner slots
  function getOwners(WalletMainLib.WalletData storage self) constant returns (address[51]) {
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
  function getOwnerIndex(WalletMainLib.WalletData storage self, address _owner) constant returns (uint) {
    return self.ownerIndex[_owner];
  }

  /// @dev Get max number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint Maximum number of owners
  function getMaxOwners(WalletMainLib.WalletData storage self) constant returns (uint) {
    return self.maxOwners;
  }

  /// @dev Get number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint Number of owners
  function getOwnerCount(WalletMainLib.WalletData storage self) constant returns (uint) {
    return self.owners.length - 1;
  }

  /// @dev Get sig requirements for administrative changes
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredAdmin(WalletMainLib.WalletData storage self) constant returns (uint) {
    return self.requiredAdmin;
  }

  /// @dev Get sig requirements for minor tx spends
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredMinor(WalletMainLib.WalletData storage self) constant returns (uint) {
    return self.requiredMinor;
  }

  /// @dev Get sig requirements for major tx spends
  /// @param self Wallet in contract storage
  /// @return uint Number of sigs required
  function getRequiredMajor(WalletMainLib.WalletData storage self) constant returns (uint) {
    return self.requiredMajor;
  }

  /// @dev Get current day spend for token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint[2] 0-index is day timestamp, 1-index is the day spend
  function getCurrentSpend(WalletMainLib.WalletData storage self, address _token) constant returns (uint[2]) {
    uint[2] memory cs;
    cs[0] = self.currentSpend[_token][0];
    cs[1] = self.currentSpend[_token][1];
    return cs;
  }

  /// @dev Get major tx threshold per token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint Threshold amount
  function getMajorThreshold(WalletMainLib.WalletData storage self, address _token) constant returns (uint) {
    return self.majorThreshold[_token];
  }

  /// @dev Get last 10 transactions for the day, fixed at 10 until fork
  /// @param self Wallet in contract storage
  /// @param _date Timestamp of day requested
  /// @return bytes32[10] Last 10 tx's starting with latest
  function getTransactions(WalletMainLib.WalletData storage self, uint _date) constant returns (bytes32[10]) {
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
  function getTransactionLength(WalletMainLib.WalletData storage self, bytes32 _id) constant returns (uint) {
    return self.transactionInfo[_id].length;
  }

  /// @dev Get list of confirmations for a tx, use getTransactionLength to get latest number
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _number The transaction index number
  /// @return uint256[50] Returns list of confirmations, fixed at 50 until fork
  function getTransactionConfirms(WalletMainLib.WalletData storage self,
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
  function getTransactionConfirmCount(WalletMainLib.WalletData storage self,
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
  function getTransactionSuccess(WalletMainLib.WalletData storage self,
                                 bytes32 _id,
                                 uint _number)
                                 constant returns (bool)
  {
    return self.transactionInfo[_id][_number].success;
  }
}
