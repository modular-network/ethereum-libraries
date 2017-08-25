WalletLib
=========================   

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A wallet library [provided by Majoolr](https://github.com/Majoolr "Majoolr's Github") to use for multisig wallet contract deployment.   

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Libraray Address](#libraray-address)
- [License and Warranty](#license-and-warranty)
- [How to install](#how-to-install)
  - [Truffle Installation](#truffle-installation)
    - [Manual Install](#manual-install)
    - [Testing the library in truffle](#testing-the-library-in-truffle)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
  - [Basic Usage](#basic-usage)
  - [Usage Example](#usage-example)
- [Functions](#functions)
  - [Primary Functions](#primary-functions)
  - [Administrative Functions](#administrative-functions)
  - [Getter Functions](#getter-functions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Libraray Address   

**ENS**:    
**Main Ethereum Network**:    
**Rinkeby Test Network**:    
**Ropsten Test Network**:    

## License and Warranty   

Be advised that while we strive to provide professional grade, tested code we cannot guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE "MIT License") and as such we will not be held liable for lost funds, etc. Please use your best judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
## How to install

### Truffle Installation

**version 3.4.6**   

First install truffle via npm using `npm install -g truffle` .   

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual Install

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.   

1. Place the WalletLib.sol file in your truffle `contracts/` directory.
2. Place the WalletLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var WalletLib = artifacts.require("./WalletLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourOtherContract = artifacts.require("./YourOtherContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(WalletLib, {overwrite: false});
  deployer.link(WalletLib, YourOtherContract);
  deployer.deploy(YourOtherContract);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(WalletLib, {overwrite: false})`. This prevents deploying the library onto the main network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. `git clone --recursive` or download the truffle directory.   
   Each folder in the truffle directory correlates to the folders in your truffle installation.   
2. Place each file in their respective directory in **your** truffle project.   
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Start a testrpc node](https://github.com/ethereumjs/testrpc \"testrpc's Github\")   
   This particular library needs specific flags set due to gas requirements. Use the following string when starting the testrpc:   

   `testrpc --gasLimit 0xffffffffffff --account="0xfacec5711eb0a84bbd13b9782df26083fc68cf41b2210681e4d478687368fdc3,100000000000000000000000000" --account="0xb7d90a23546b263a9a68a26ed7045cd6ce7d3b0dfa7d3c7b66434a4a89453cf7,100000000000000000000000000" --account="0x58823bde84d19ad2bdb6739f9ef1fc8ca4ba0c617ecc9a1fa675282175a9bc02,100000000000000000000000000" --account="0x42891283028bba9611583fcaa0dea947251b9f980a1e3d9858cd33b0e8077195,100000000000000000000000000" --account="0x6009fc3fda6c5976cfecc36b9c0c9423f78bcc971ade88f32c0e016225c1601a,100000000000000000000000000" --account="0xe598179ebee08a9b1f1afaef6ac526e5cfe615d87831aed8b080c988773bda6d,100000000000000000000000000"`

4. In your terminal go to your truffle project directory and run `truffle test`.   

### solc Installation

**version 0.4.13**

For direction and instructions on how the Solidity command line compiler works [see the documentation](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").   

#### With standard JSON input

[The Standard JSON Input](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#input-description "Standard JSON Input") provides an easy interface to include libraries. Include the following as part of your JSON input file:

```json
{
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      ...
      ...
    },
    "WalletLib.sol": {
      "content": "[Contents of WalletLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "WalletLib": ""
      }
    }
  }
}
```

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:   

`--libraries "WalletLib:"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and inlcude this library as follows:   

`--libraries "WalletLib:"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "WalletLib:"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.13**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.   

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourContract.sol','utf8');
var lib = fs.readFileSync('./path/to/WalletLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "WalletLib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "WalletLib": ""
      }
    }
    ...
  }
}

var output = JSON.parse(solc.compileStandardWrapper(JSON.stringify(input)));

//Where the output variable is a standard JSON output object.
```

#### Solc-js Installation via Linking

Solc-js also provides a linking method if you have compiled binary code already with the placeholder. To link this library the call would be:

```js
bytecode = solc.linkBytecode(bytecode, { 'WalletLib': '' });
```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

### Basic Usage

The WalletLib library provides all of the functionality needed to generate a fully functional multisig wallet. The wallet generated will have some of these benefits and characteristics:

   * Can have up to 50 wallet owners.
   * Allows for signature requirements to be defined for three types of operations: administrative, minor transactions, and major transactions.
          **Administrative:** These are transactions that change signature requirements, add owners, remove owners, etc.
          **Minor Transactions:** These are ether or token transfers below a set daily threshold.
          **Major Transactions:** These are ether or token transfers at or above a set daily threshold.
   * Allows a major transaction threshold to be set individually for any token.
   * Provides a transaction hash for any pending transaction such as is implemented in Gav's wallet, allowing subsequent signatures to be submitted by hash.
   * Can create other contracts from within the wallet.
   * Any new token will automatically have a major threshold of 0 until a threshold is defined by the wallet owners.
   * Allows signatures to be revoked at any point in time prior to the transaction confirming.

The wallet contract should put the `init` function in the constructor with the required parameters given. Once deployed, owners can initiate any transaction by calling the appropriate function with the required data for admin functions, transfer or value data for token or ether transactions, or contract data for deploying new contracts. Most transaction requests end with a `bool` and `bytes` parameter. The `bool` parameter should be true for any transaction being initiated or confirmed and false for any signature revocation. The `bytes` parameter should be the msg.data passed automatically by the wallet contract. [See our example wallet contract](https://www.github.com/Majoolr/ethereum-contracts \"Majoolr repo\") to get a better idea of its implementation.

Most functions return two parameters, a `bool` and a `bytes32`. The wallet library functions will generally return false and log an error event when submitted parameters are either wrong or the call will not work. In the case of a non-owner attempting to submit a transaction or any failure during actual execution, the wallet library will throw a standard out of gas error with no reason in order to successfully revert changes. These functions will return true if any confirm or revocation call is successful. The functions that return a `bytes32` will also log this value in an event. Owners may choose to use the generic `confirmTx` or `revokeConfirm` functions by providing the id for any transaction already initiated, a concept artfully developed by Gav of York himself.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, a non-owners ability to gain access to your wallet, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://majoolr.io \"Majoolr website\") if you have discovered any issues or vulnerabilities with this library.

### Usage Example

```
pragma solidity ^"+sver+";

import "./WalletLib.sol";

contract YourWalletContract {
  using WalletLib for WalletLib.WalletData;

  WalletLib.WalletData public wallet;

  event Deposit(uint value);

  function YourWalletContract() {
    address[] memory _owners = new address[](5);//Define initial account owners with your owners
    _owners[0] = 0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623;
    _owners[1] = 0x40333d950b4c682e8aad143c216af52877d828bf;
    _owners[2] = 0x0a1f4fcde83ba12ee8343488964811218da3e00e;
    _owners[3] = 0x79b63228ff63659248b7c688870de388bdcf0c14;
    _owners[4] = 0x36994c7cff11859ba8b9715120a68aa9499329ee;
    wallet.init(_owners,4,3,1,100000000000000000000);
  }

  //Payable fallback function
  function() payable {
    Deposit(msg.value);
  }

  /*Getters*/

  function owners() constant returns (address[51]) {//Returns fixed array until fork
    return wallet.getOwners();
  }

  function ownerIndex(address _owner) constant returns (uint) {
    return wallet.getOwnerIndex(_owner);
  }

  ...
}
```

**[See our contract repo](https://www.github.com/Majoolr/ethereum-contracts "Majoolr repo") for a full implementation example of this library**

## Functions

The following is the list of functions available to use in your smart contract.

### Primary Functions

#### init(WalletLib.WalletData storage, address[], uint256, uint256, uint256, uint256)   
*(WalletLib.sol, line 93)*

Constructor. Initializes the wallet in the calling contract's storage.  Caller passes in owners and signature settings for the wallet.  Owners must be valid ethereum addresses and signature requirements must be greater than zero and less than or equal to the number of owners. _majorThreshold parameter should set the daily spend limit for minor ether transactions in wei.

##### Arguments
**WalletLib.WalletData** self   
**adress[]** _owners   
**uint256** _requiredAdmin   
**uint256** _requiredMajor   
**uint256** _requiredMinor   
**uint256** _majorThreshold

##### Returns
**bool**   

#### serveTx(WalletLib.WalletData, address, uint256, bytes, bool, bytes)   
*(WalletLib.sol, line 342)*

Sends the specified amount of Ether or tokens from the Wallet to an address.

##### Arguments
**WalletLib.WalletData** self The storage wallet in the calling contract.   
**address** _to Intended recipient of transaction.   
**uint256** _value Amount of Ether to be sent.   
**bytes** txData Any transaction data to be sent to recipient.   
**bool** confirm True if initiaing or confirming a transaction, false if revoking a signature.   
**bytes** _data Data for this call sent automatically by the calling contract.   

##### Returns
**bool** True if transaction confirmed or revoked successfully   
**bytes32** The transaction id which can be provided to `confirmTx` or `revokeConfirm`.   

#### confirmTx(WalletLib.WalletData storage, bytes32)   
*(WalletLib.sol, line 434)*

Confirms the specified pending transaction with the sender's signature.  If the transaction does not exist, the call will fail.  If the callers signature is the final signature needed for the transaction to succeed, the transaction will execute.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id

##### Returns
**bool**   

#### revokeConfirm(WalletLib.WalletData storage, bytes32)   
*(WalletLib.sol, line 473)*

Revokes the sender's confirmation from a pending transaction.  If the transaction does not exist or has already succeeded, the call will fail.  The caller also needs to have already confirmed the transaction.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id

##### Returns
**bool**   

### Administrative Functions

These functions are for performing actions that change the administrative settings of the Wallet contract such as owners, major/minor transaction threshholds, and number of signatures required.  Like normal wallet transactions, these functions require a certain number of signatures from the wallet owners, indicated by requiredAdmin.  A call to one of these functions acts as a confirmation of the action.  If it is the first confirmation, the transaction is created and the confirmation is recorded.  When the confirmations reach the required number, the action is executed.  If an owner calls these functions for a change they have already confirmed, with the correct arguments for the pending transaction, with the confirm flag set to false, their confirmation for the transaction will be revoked.   

#### changeOwner(WalletLib.WalletData storage, address, address, bool, bytes)   
*(WalletLib.sol, line 524)*

Changes owner address to a new address. bool should be true if confirming or initiating the transaction and false if revoking a confirmation. bytes parameter should be passed as msg.data from wallet contract.

##### Arguments
**WalletLib.WalletData** self   
**adress** _from   
**address** _to   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### addOwner(WalletLib.WalletData storage, address, bool, bytes)   
*(WalletLib.sol, line 593)*

Adds a new user as an owner of the wallet.

##### Arguments
**WalletLib.WalletData** self   
**adress** _newOwner   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### removeOwner(WalletLib.WalletData storage, address, bool, bytes)   
*(WalletLib.sol, line 663)*

Removes an existing owner from the wallet.

##### Arguments
**WalletLib.WalletData** self   
**adress** _ownerRemoving   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### changeRequiredAdmin(WalletLib.WalletData storage, uint256, bool, bytes)   
*(WalletLib.sol, line 733)*

Changes the number of signatures required to confirm administrative changes.

##### Arguments
**WalletLib.WalletData** self   
**uint256** _requiredAdmin   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### changeRequiredMajor(WalletLib.WalletData storage, uint256, bool, bytes)   
*(WalletLib.sol, line 799)*

Changes the number of signatures required to confirm major transactions.

##### Arguments
**WalletLib.WalletData** self   
**uint256** _requiredMajor   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### changeRequiredMinor(WalletLib.WalletData storage, uint256, bool, bytes)   
*(WalletLib.sol, line 865)*

Changes the number of signatures required to confirm minor transactions.

##### Arguments
**WalletLib.WalletData** self   
**uint256** _requiredMinor   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

#### changeMajorThreshold(WalletLib.WalletData storage, address, address, bool, bytes)   
*(WalletLib.sol, line 932)*

Changes the threshold of tokens or wei spent per day that needs to be crossed for the transaction to be considered major.

##### Arguments
**WalletLib.WalletData** self   
**adress** _from   
**address** _to   
**bool** _confirm   
**bytes** _data

##### Returns
**bool**   
**bytes32**   

### Getter Functions

#### getOwners(WalletLib.WalletData storage)   
*(WalletLib.sol, line 994)*

Get list of wallet owners, will return fixed 50 item array until Metro fork.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**address[51]**   

#### getOwnerIndex(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1006)*

Get index of an owner.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getMaxOwners(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1013)*

Get max number of wallet owners.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getOwnerCount(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1020)*

Get number of wallet owners.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getRequiredAdmin(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1027)*

Get sig requirements for administrative changes.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getRequiredMinor(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1034)*

Get sig requirements for minor tx spends.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getRequiredMajor(WalletLib.WalletData storage)   
*(WalletLib.sol, line 1041)*

Get sig requirements for major tx spends.

##### Arguments
**WalletLib.WalletData** self   

##### Returns
**uint256**   

#### getCurrentSpend(WalletLib.WalletData storage, address)   
*(WalletLib.sol, line 1049)*

Get current day spend for token.

##### Arguments
**WalletLib.WalletData** self   
**address** _token Address of the token contract, use 0 for ether.   

##### Returns
**uint256[2]** 0-index is day timestamp, 1-index is the day spend   

#### getMajorThreshold(WalletLib.WalletData storage, address)   
*(WalletLib.sol, line 1060)*

Get major tx threshold per token.

##### Arguments
**WalletLib.WalletData** self   
**address** _token   

##### Returns
**uint256**   

#### getTransactions(WalletLib.WalletData storage, uint256)   
*(WalletLib.sol, line 1068)*

Get last 10 transactions for the day, fixed at 10 until fork.

##### Arguments
**WalletLib.WalletData** self   
**uint256** _date Timestamp of the day.   

##### Returns
**bytes32[10]** The id for each of the last 10 transactions.   

#### getTransactionLength(WalletLib.WalletData storage, bytes32)   
*(WalletLib.sol, line 1081)*

Get the number of tx's with the same id.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id   

##### Returns
**uint256** Number of transactions with this id, can be used to query for specific tx, see `getTransactionConfirms`   

#### getTransactionConfirms(WalletLib.WalletData storage, bytes32, uint256)   
*(WalletLib.sol, line 1090)*

Get list of confirmations for a tx, use `getTransactionLength` to get latest number.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id   
**uint256** _number   

##### Returns
**uint256[50]** List of confirmations, fixed at 50 items until Metro fork   

#### getTransactionConfirmCount(WalletLib.WalletData storage, bytes32, uint256)   
*(WalletLib.sol, line 1107)*

Retrieve tx confirmation count.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id   
**uint256** _number   

##### Returns
**uint256** The current number of tx confirmations.   

#### getTransactionSuccess(WalletLib.WalletData storage, bytes32, uint256)   
*(WalletLib.sol, line 1120)*

Retrieve if transaction was successful.

##### Arguments
**WalletLib.WalletData** self   
**bytes32** _id   
**uint256** _number   

##### Returns
**bool**   
