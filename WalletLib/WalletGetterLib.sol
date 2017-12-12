pragma solidity 0.4.18;

/**
 * @title Wallet Getter Library
 * @author Modular.network
 *
 * version 1.1.0
 * Copyright (c) 2017 Modular, LLC
 * The MIT License (MIT)
 * https://github.com/Modular-network/ethereum-libraries/blob/master/LICENSE
 *
 * The Wallet Library family is inspired by the multisig wallets built by Consensys
 * at https://github.com/ConsenSys/MultiSigWallet and Parity at
 * https://github.com/paritytech/contracts/blob/master/Wallet.sol with added
 * functionality. Modular works on open source projects in the Ethereum
 * community with the purpose of testing, documenting, and deploying reusable
 * code onto the blockchain to improve security and usability of smart contracts.
 * Modular also strives to educate non-profits, schools, and other community
 * members about the application of blockchain technology. For further
 * information: modular.network, consensys.net, paritytech.io
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
  function getOwners(WalletMainLib.WalletData storage self) public view returns (address[51]) {
    address[51] memory o;
    for(uint256 i = 0; i<self.owners.length; i++){
      o[i] = self.owners[i];
    }
    return o;
  }

  /// @dev Get index of an owner
  /// @param self Wallet in contract storage
  /// @param _owner Address of owner
  /// @return uint256 Index of the owner
  function getOwnerIndex(WalletMainLib.WalletData storage self, address _owner) public view returns (uint256) {
    return self.ownerIndex[_owner];
  }

  /// @dev Get max number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint256 Maximum number of owners
  function getMaxOwners(WalletMainLib.WalletData storage self) public view returns (uint256) {
    return self.maxOwners;
  }

  /// @dev Get number of wallet owners
  /// @param self Wallet in contract storage
  /// @return uint256 Number of owners
  function getOwnerCount(WalletMainLib.WalletData storage self) public view returns (uint256) {
    return self.owners.length - 1;
  }

  /// @dev Get sig requirements for administrative changes
  /// @param self Wallet in contract storage
  /// @return uint256 Number of sigs required
  function getRequiredAdmin(WalletMainLib.WalletData storage self) public view returns (uint256) {
    return self.requiredAdmin;
  }

  /// @dev Get sig requirements for minor tx spends
  /// @param self Wallet in contract storage
  /// @return uint256 Number of sigs required
  function getRequiredMinor(WalletMainLib.WalletData storage self) public view returns (uint256) {
    return self.requiredMinor;
  }

  /// @dev Get sig requirements for major tx spends
  /// @param self Wallet in contract storage
  /// @return uint256 Number of sigs required
  function getRequiredMajor(WalletMainLib.WalletData storage self) public view returns (uint256) {
    return self.requiredMajor;
  }

  /// @dev Get current day spend for token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint256[2] 0-index is day timestamp, 1-index is the day spend
  function getCurrentSpend(WalletMainLib.WalletData storage self, address _token) public view returns (uint256[2]) {
    uint256[2] memory cs;
    cs[0] = self.currentSpend[_token][0];
    cs[1] = self.currentSpend[_token][1];
    return cs;
  }

  /// @dev Get major tx threshold per token
  /// @param self Wallet in contract storage
  /// @param _token Address of token, 0 for ether
  /// @return uint256 Threshold amount
  function getMajorThreshold(WalletMainLib.WalletData storage self, address _token) public view returns (uint256) {
    return self.majorThreshold[_token];
  }

  /// @dev Get the number of tx's with the same id
  /// @param self Wallet in contract storage
  /// @param _id ID of transactions requested
  /// @return uint256 Number of tx's with same ID
  function getTransactionLength(WalletMainLib.WalletData storage self, bytes32 _id) public view returns (uint256) {
    return self.transactionInfo[_id].length;
  }

  /// @dev Get list of confirmations for a tx, use getTransactionLength to get latest number
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _txIndex The transaction index number
  /// @return uint256[50] Returns list of confirmations, fixed at 50 until fork
  function getTransactionConfirms(WalletMainLib.WalletData storage self,
                                  bytes32 _id,
                                  uint256 _txIndex)
                                  public view returns (uint256[50])
  {
    uint256[50] memory tc;
    for(uint256 i = 0; i<self.transactionInfo[_id][_txIndex].confirmedOwners.length; i++){
      tc[i] = self.transactionInfo[_id][_txIndex].confirmedOwners[i];
    }
    return tc;
  }

  /// @dev Retrieve tx confirmation count
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _txIndex The transaction index number
  /// @return uint256 Returns the current number of tx confirmations
  function getTransactionConfirmCount(WalletMainLib.WalletData storage self,
                           bytes32 _id,
                           uint256 _txIndex)
                           public view returns(uint256)
  {
    return self.transactionInfo[_id][_txIndex].confirmCount;
  }

  /// @dev Retrieve if transaction was successful
  /// @param self Wallet in contract storage
  /// @param _id ID of transaction requested
  /// @param _txIndex The transaction index number
  /// @return bool Returns true if tx successfully executed, false otherwise
  function getTransactionSuccess(WalletMainLib.WalletData storage self,
                                 bytes32 _id,
                                 uint256 _txIndex)
                                 public view returns (bool)
  {
    return self.transactionInfo[_id][_txIndex].success;
  }
}
