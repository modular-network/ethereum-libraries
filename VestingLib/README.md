VestingLib 
=========================   

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries) 
[![Join the chat at https://gitter.im/Modular-Network/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Modular-Network/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A Vesting library [provided by Modular-Network](https://github.com/Modular-Network "Modular's Github") for setting up a contract that can vest ETH or tokens linearly over a set period of time.  

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
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
- [Functions](#functions)
    - [init(VestingLib.VestingStorage storage, address, bool, uint256, uint256, uint256)](#initvestinglibvestingstorage-storage-address-bool-uint256-uint256-uint256)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [initializeETHBalance(VestingLib.VestingStorage storage, uint256)](#initializeethbalancevestinglibvestingstorage-storage-uint256)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [initializeTokenBalance(VestingLib.VestingStorage storage, CrowdsaleToken token, uint256)](#initializetokenbalancevestinglibvestingstorage-storage-crowdsaletoken-token-uint256)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [registerUser(VestingLib.VestingStorage storage, address, uint256, uint256)](#registeruservestinglibvestingstorage-storage-address-uint256-uint256)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [registerUsers(VestingLib.VestingStorage storage, address[], uint256, uint256)](#registerusersvestinglibvestingstorage-storage-address-uint256-uint256)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [unregisterUser(VestingLib.VestingStorage storage, address)](#unregisteruservestinglibvestingstorage-storage-address)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
    - [unregisterUsers(VestingLib.VestingStorage storage, address[])](#unregisterusersvestinglibvestingstorage-storage-address)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [swapRegistration(VestingLib.VestingStorage storage, address)](#swapregistrationvestinglibvestingstorage-storage-address)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [withdrawETH(VestingLib.VestingStorage storage)](#withdrawethvestinglibvestingstorage-storage)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [withdrawTokens(VestingLib.VestingStorage storage, CrowdsaleToken)](#withdrawtokensvestinglibvestingstorage-storage-crowdsaletoken)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)
    - [sendETH(VestingLib.VestingStorage storage, address)](#sendethvestinglibvestingstorage-storage-address)
      - [Arguments](#arguments-10)
      - [Returns](#returns-10)
    - [sendTokens(VestingLib.VestingStorage storage, CrowdsaleToken, address)](#sendtokensvestinglibvestingstorage-storage-crowdsaletoken-address)
      - [Arguments](#arguments-11)
      - [Returns](#returns-11)
    - [ownerWithdrawExtraETH(VestingLib.VestingStorage storage)](#ownerwithdrawextraethvestinglibvestingstorage-storage)
      - [Arguments](#arguments-12)
      - [Returns](#returns-12)
    - [ownerWithdrawExtraTokens(VestingLib.VestingStorage storage, CrowdsaleToken)](#ownerwithdrawextratokensvestinglibvestingstorage-storage-crowdsaletoken)
      - [Arguments](#arguments-13)
      - [Returns](#returns-13)
    - [getPercentReleased(VestingLib.VestingStorage storage)](#getpercentreleasedvestinglibvestingstorage-storage)
      - [Arguments](#arguments-14)
      - [Returns](#returns-14)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address   

**ENS**: VestingLib.modular.eth   
**Main Ethereum Network**:    
**Ropsten Test Network**:    
**Rinkeby Test Network**:    

## License and Warranty   

Be advised that while we strive to provide professional grade, tested code we cannot guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE "MIT License") and as such we will not be held liable for lost funds, etc. Please use your best judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
## How to install

### Truffle Installation

**version 3.4.9**   

First install truffle via npm using `npm install -g truffle` .   

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual Install

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.   

1. Place the VestingLib.sol file in your truffle `contracts/` directory.
2. Place the VestingLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var VestingLib = artifacts.require("./VestingLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourOtherContract = artifacts.require("./YourOtherContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(VestingLib, {overwrite: false});
  deployer.link(VestingLib, YourOtherContract);
  deployer.deploy(YourOtherContract);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(VestingLib, {overwrite: false})`. This prevents deploying the library onto the main network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/VestingLib/truffle`.    
2. Place each file in their respective directory in **your** truffle project.   
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Start a testrpc node](https://github.com/ethereumjs/testrpc \"testrpc's Github\")   
   This particular library needs specific flags set due to gas requirements. Use the following string when starting the testrpc:   

   `testrpc`

4. In your terminal go to your truffle project directory and run `truffle test`.   

### solc Installation

**version 0.4.15**

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
    "VestingLib.sol": {
      "content": "[Contents of VestingLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "VestingLib": ""
      }
    }
  }
}
```

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:   

`--libraries "VestingLib:"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and inlcude this library as follows:   

`--libraries "VestingLib:"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "VestingLib:"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.15**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.   

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourContract.sol','utf8');
var lib = fs.readFileSync('./path/to/VestingLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "VestingLib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "VestingLib": ""
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
bytecode = solc.linkBytecode(bytecode, { 'VestingLib': '' });
```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

### Basic Usage

The Vesting library allows the owner to set up a contract to have linear vesting of ETH or tokens over a specified period of time.

The owner initializes the contract with an indication of whether it is tokens or ETH, a start time, end time, and the number of times the balance vests.
It calculates the interval between vests and the percentage vested at each interval

Before the vesting starts, the owner has to initialize the balance of the contract.  If it is ETH, he will call the initializeETHBalance function with an accompanying payment
If if is tokens, the owner has to send tokens to the contract, then call the initializeTokenBalance function.

The owner is also able to register and unregister users before the sale starts.  Users are also able to swap their registration with another address if they choose whenever they want.

Users can call the withdraw function whenever they want and it calculates the amount they are allowed to withdraw at that point.  It then sends the ETH or tokens if there is any available.  

The owner can also send the vested ETH or tokens directly to registrants during the vesting.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://modular.network \"Modular's website\") if you have discovered any issues or vulnerabilities with this library.

## Functions

The following is the list of functions available to use in your smart contract.

#### init(VestingLib.VestingStorage storage, address, bool, uint256, uint256, uint256)   
*(VestingLib.sol, line 87)*

Initializes the storage variables in the vesting contract.

##### Arguments
**VestingLib.VestingStorage storage** self 
**address** _owner the owner of the vesting contract 
**bool** _isToken indicates if the contract is vesting tokens or ETH 
**uint256** _startTime the start time of the vesting 
**uint256** _endTime the end time of the vesting 
**uint256** _numReleases number of times the vesting will release funds to participants 

##### Returns
**bool**  

#### initializeETHBalance(VestingLib.VestingStorage storage, uint256)   
*(VestingLib.sol, line 114)*

function owner has to call before the vesting starts to initialize the ETH balance of the contract.

##### Arguments
**VestingLib.VestingStorage storage** self 
**uint256** _balance the balance that is being vested. msg.value from the contract call 

##### Returns
**bool**  

#### initializeTokenBalance(VestingLib.VestingStorage storage, CrowdsaleToken token, uint256)   
*(VestingLib.sol, line 130)*

function owner has to call before the vesting starts to initialize the Token balance of the contract.

##### Arguments
**VestingLib.VestingStorage storage** self 
**CrowdsaleToken** token the token contract instance that is being used for the vesting 
**uint256** _balance the balance that is being vested. owner has to have sent tokens to the contract before calling this function 

##### Returns
**bool**   

#### registerUser(VestingLib.VestingStorage storage, address, uint256, uint256)   
*(VestingLib.sol, line 150)*

Registers an individual user for the crowdsale.  Only the owner can call this function and it can only be called for an unregistered address before the vesting starts

##### Arguments
**VestingLib.VestingStorage** self   
**address** _registrant Address who is registering for the vesting. 
**uint256** _vestAmount amount of ETH or tokens to vest for the address
**uint256** _bonus amount of bonus tokens or eth if no withdrawal prior to endTime

##### Returns
**bool**   

#### registerUsers(VestingLib.VestingStorage storage, address[], uint256, uint256)   
*(VestingLib.sol, line 198)*

Registers a group of users for the vesting.  Only the owner can call this function.

##### Arguments
**VestingLib.VestingStorage** self   
**address[]** _registrants Addresses who are registering for the vesting. 
**uint256** _vestAmount amount of ETH or tokens to vest for each address
**uint256** _bonus amount of bonus tokens or eth if no withdrawal prior to endTime

##### Returns
**bool**   

#### unregisterUser(VestingLib.VestingStorage storage, address)   
*(VestingLib.sol, line 217)*

unRegisters an individual user for the vesting.  

##### Arguments
**VestingLib.VestingStorage** self   
**address** _registrant Address of a buyer who is unregistering for the vesting 

##### Returns
**bool**   

#### unregisterUsers(VestingLib.VestingStorage storage, address[])   
*(VestingLib.sol, line 250)*

UnRegisters a group of users for the vesting.

##### Arguments
**VestingLib.VestingStorage** self   
**address[]** _registrants Addresses of registrants who are unregistering from the vesting. 

##### Returns
**bool**   

#### swapRegistration(VestingLib.VestingStorage storage, address)   
*(VestingLib.sol, line 263)*

allows a participant to replace themselves in the vesting schedule with a new address

##### Arguments
**VestingLib.VestingStorage** self   
**address** _replacementRegistrant new address to replace the caller with 

##### Returns
**bool**   

#### withdrawETH(VestingLib.VestingStorage storage)   
*(VestingLib.sol, line 309)*

Allows the participants to withdraw their vested ETH, plus the bonus, if applicable

##### Arguments
**VestingLib.VestingStorage** self   

##### Returns
**bool**   

#### withdrawTokens(VestingLib.VestingStorage storage, CrowdsaleToken)   
*(VestingLib.sol, line 352)*

Allows the participants to withdraw their vested tokens, plus the bonus, if applicable

##### Arguments
**VestingLib.VestingStorage** self   
 **CrowdsaleToken token** token the token contract instance being vested

##### Returns
**bool**   

#### sendETH(VestingLib.VestingStorage storage, address)   
*(VestingLib.sol, line 395)*

allows the owner to send vested ETH to participants

##### Arguments
**VestingLib.VestingStorage** self   
**address** _beneficiary vesting participant to send ETH to

##### Returns
**bool**   

#### sendTokens(VestingLib.VestingStorage storage, CrowdsaleToken, address)   
*(VestingLib.sol, line 440)*

allows the owner to send vested tokens to participants

##### Arguments
**VestingLib.VestingStorage** self   
**CrowdsaleToken** token token contract instance being vested
 **address** _beneficiary vesting participant to send ETH to

##### Returns
**bool**   

#### ownerWithdrawExtraETH(VestingLib.VestingStorage storage)   
*(VestingLib.sol, line 482)*

allows the owner to withdraw any ETH left in the contract

##### Arguments
**VestingLib.VestingStorage** self   

##### Returns
**bool**   

#### ownerWithdrawExtraTokens(VestingLib.VestingStorage storage, CrowdsaleToken)   
*(VestingLib.sol, line 498)*

allows the owner to withdraw and tokens left in the contract

##### Arguments
**VestingLib.VestingStorage** self   
**CrowdsaleToken** token token contract instance being vested

##### Returns
**uint256**   

#### getPercentReleased(VestingLib.VestingStorage storage)   
*(VestingLib.sol, line 513)*

 Returns the percentage of the vesting that has been released at the current moment

##### Arguments
**VestingLib.VestingStorage** self   

##### Returns
**uint256** percentage released in vesting