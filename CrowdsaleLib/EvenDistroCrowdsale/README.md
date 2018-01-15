EvenDistroCrowdsaleLib
=========================   

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)   

A crowdsale library [provided by Modular](https://modular.network "Modular's Website") to use for pre-registered, even token distribution crowdsale contract deployment.   

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
  - [v2.2.1](#v221)
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
- [Change Log](#change-log)
  - [v2.2.1](#v221-1)
  - [v2.1.0](#v210)
  - [v2.0.0](#v200)
- [Functions](#functions)
  - [init](#initevendistrocrowdsalelibevendistrocrowdsalestorage-storage-address-uint256-uint256-uint8-uint256-bool-crowdsaletoken)
    - [Arguments](#arguments)
    - [Returns](#returns)
  - [registerUser](#registeruserevendistrocrowdsalelibevendistrocrowdsalestorage-storage-address)
    - [Arguments](#arguments-1)
    - [Returns](#returns-1)
  - [registerUsers](#registerusersevendistrocrowdsalelibevendistrocrowdsalestorage-storage-address)
    - [Arguments](#arguments-2)
    - [Returns](#returns-2)
  - [unregisterUser](#unregisteruserevendistrocrowdsalelibevendistrocrowdsalestorage-storage-address)
    - [Arguments](#arguments-3)
    - [Returns](#returns-3)
  - [unregisterUsers](#unregisterusersevendistrocrowdsalelibevendistrocrowdsalestorage-storage-address)
    - [Arguments](#arguments-4)
    - [Returns](#returns-4)
  - [calculateAddressTokenCap](#calculateaddresstokencapevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-5)
    - [Returns](#returns-5)
  - [receivePurchase](#receivepurchaseevendistrocrowdsalelibevendistrocrowdsalestorage-storage-uint256)
    - [Arguments](#arguments-6)
    - [Returns](#returns-6)
  - [setTokens](#settokensevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-7)
    - [Returns](#returns-7)
  - [withdrawTokens](#withdrawtokensevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-8)
    - [Returns](#returns-8)
  - [withdrawLeftoverWei](#withdrawleftoverweievendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-9)
    - [Returns](#returns-9)
  - [withdrawOwnerEth](#withdrawownerethevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-10)
    - [Returns](#returns-10)
  - [getSaleData](#getsaledataevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-11)
    - [Returns](#returns-11)
  - [getTokensSold](#gettokenssoldevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-12)
    - [Returns](#returns-12)
  - [crowdsaleActive](#crowdsaleactiveevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-13)
    - [Returns](#returns-13)
  - [crowdsaleEnded](#crowdsaleendedevendistrocrowdsalelibevendistrocrowdsalestorage-storage)
    - [Arguments](#arguments-14)
    - [Returns](#returns-14)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address   

### v2.2.1

**ENS**: TBD   
**Main Ethereum Network**: 0x7A1Bc60B7FfAD01aCEB258e72B4ecec6573EA4f9    
**Ropsten Test Network**: Not available at this time.    
**Rinkeby Test Network**: 0x664DE7B68af5fAB00aB92942F722De286823F4aE    

## License and Warranty   

Be advised that while we strive to provide professional grade, tested code we cannot guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE "MIT License") and as such we will not be held liable for lost funds, etc. Please use your best judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## How to install

### Truffle Installation

**version 4.0.1**   

First install truffle via npm using `npm install -g truffle` .   

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual Install

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.   

1. Place the CrowdsaleLib.sol (from the root CrowdsaleLib directory) and EvenDistroCrowdsaleLib.sol file in your truffle `contracts/` directory.
2. Place the CrowdsaleLib.json and EvenDistroCrowdsaleLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol")
var EvenDistroCrowdsaleLib = artifacts.require("./EvenDistroCrowdsaleLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourCrowdsaleContract = artifacts.require("./YourCrowdsaleContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.deploy(EvenDistroCrowdsaleLib, {overwrite: false});
  deployer.link(CrowdsaleLib, YourCrowdsaleContract)
  deployer.link(EvenDistroCrowdsaleLib, YourCrowdsaleContract);
  deployer.deploy(YourCrowdsaleContract, arg1, arg2,...);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(EvenDistroCrowdsaleLib, {overwrite: false})`. This prevents deploying the library onto the main network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/EvenDistroCrowdsaleLib/truffle`.    
2. Place each file in their respective directory in **your** truffle project.   
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Download and start Ganache](http://truffleframework.com/ganache/ "Ganache Download")
4. In your terminal go to your truffle project directory.
5. Ensure the `development` object in your truffle.js file points to the same port Ganache uses, default is 7545.
6. Run `truffle test`.   

### solc Installation

**version 0.4.18**

For direction and instructions on how the Solidity command line compiler works [see the documentation](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").   

#### With standard JSON input

[The Standard JSON Input](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#input-description "Standard JSON Input") provides an easy interface to include libraries. Include the following as part of your JSON input file:

```json
{
  "language": "Solidity",
  "sources":
  {
    "YourCrowdsaleContract.sol": {
      ...
      ...
    },
    "CrowdsaleLib.sol": {
      "content": "[Contents of CrowdsaleLib.sol]"
    },
    "EvenDistroCrowdsaleLib.sol": {
      "content": "[Contents of EvenDistroCrowdsaleLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourCrowdsaleContract.sol": {
        "CrowdsaleLib": "0x4A0a5236E4D1aE19fc00C167E1D33f37870f53b1",
        "EvenDistroCrowdsaleLib": "0x7A1Bc60B7FfAD01aCEB258e72B4ecec6573EA4f9"
      }
    }
  }
}
```

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include both deployed libraries in your bytecode create a file with one library string per line  as follows:    

```
"CrowdsaleLib:0x4A0a5236E4D1aE19fc00C167E1D33f37870f53b1"
"EvenDistroCrowdsaleLib:0x7A1Bc60B7FfAD01aCEB258e72B4ecec6573EA4f9"
```

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries filename`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.18**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.   

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourCrowdsaleContract.sol','utf8');
var crowdsaleLib = fs.readFileSync('./path/to/CrowdsaleLib.sol','utf8');
var lib = fs.readFileSync('./path/to/EvenDistroCrowdsaleLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourCrowdsaleContract.sol": {
      "content": file
    },
    "EvenDistroCrowdsaleLib.sol": {
      "content": lib
    },
    "CrowdsaleLib.sol": {
      "content": crowdsaleLib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourCrowdsaleContract.sol": {
        "CrowdsaleLib": "0x4A0a5236E4D1aE19fc00C167E1D33f37870f53b1",
        "EvenDistroCrowdsaleLib": "0x7A1Bc60B7FfAD01aCEB258e72B4ecec6573EA4f9"
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
bytecode = solc.linkBytecode(bytecode, { 'CrowdsaleLib': '0x4A0a5236E4D1aE19fc00C167E1D33f37870f53b1' });
```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

### Basic Usage

The Even Distribution Crowdsale library provides functionality needed to launch a crowdsale where users pre-register and there is a cap of how much ether an address can contribute. It is made up of two library contracts, a base library and a library specific to this type of crowdsale structure. Both should be included in your project. The crowdsale will have some of the following characteristics:

   * Sets a raise cap in terms of dollars and cents.
   * Allows single and batch user registration handled by the owner.
   * Can set the interval between changes in the address cap.
   * Can set a static cap for use throughout the sale, or can calculate a cap based on the number of participants registered for the sale.
   * Sets an exchange rate for dollars/ETH up to three days before the sale begins, which also calculates the cap at the same time.
   * Can set a percentage of extra tokens to burn after the sale ends with the remainder going back to the owners.

The crowdsale contract should put the `init` function in the constructor with the required parameters given. The crowdsale library functions will generally return false and log an error event when submitted parameters are either wrong or the call will not work.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://modular.network "Modular's Website") if you have discovered any issues or vulnerabilities with this library.

## Change Log

### v2.2.1

* Removes exchange rates for just tokens/eth pricing
* Removes explicit cap since the sale is capped by the number of tokens being sold

### v2.1.0

* Updates solidity compiler to v0.4.18
* Minor fixes

### v2.0.0

* This version changes the sale data structure for all crowdsales.

## Functions

The following is the list of functions available to use in your smart contract.

### init(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address, uint256[], uint256, uint8, uint256, bool, CrowdsaleToken)   
*(EvenDistroCrowdsaleLib.sol, line 86)*

Constructor. Initialize the crowdsale with owner, sale data, fall back exchange rate, raise cap (in cents), endTime, burn percentage for leftover tokens, a boolean that determines whether the address cap will increase throughout the sale, and the address of the deployed token contract. Passes some values to the base constructor then sets the crowdsale specific storage variables. The sale data consists of an array of 3-item "sets" such that, in each 3 element set, 1 is timestamp, 2 is price in cents at that time, 3 is address purchase cap at that time, 0 if no address cap. If address cap is to be determined after all registration has ended, then staticCap should be false and the address purchase cap item should indicate the percentage the base cap is increased at that timestamp. The base cap will be determined as the total raise cap divided by the number of registrants. i.e. If the raise cap is $10M and 1M people register, then the raise cap is $10/registrant and if the address purchase cap is set to 200, then the cap will increase by 200% at that timestamp. The first address cap should be set to 100.   

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address** `_owner` Address of crowdsale owner   
**uint256[]** `_saleData` Array of 3 item sets such that, in each 3 element set, 1 is timestamp, 2 is price in tokens/ETH at that time, 3 is address purchase cap at that time, 0 if no address cap. If staticCap is true, item 3 should be expressed in terms of tokens, if false, staticCap should be expressed in terms of percentage increase. The first timestamp is the start of the sale, and if percentages, item 3 must be at or above 100 or zero, with zero indicating no address cap.   
**uint256** `_endTime` Timestamp of the end time.   
**uint8** `_percentBurn` Percentage of extra tokens to burn after the sale.   
**uint256** `_initialAddressTokenCap` This will set the address token cap in case the exchange rate setter is not called in time.    
**bool** `_staticCap` True if the cap is set with tokens, false if set with percentages.   
**CrowdsaleToken** `_token` Token being sold in the crowdsale.   

#### Returns
No return   

### registerUser(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address)   
*(EvenDistroCrowdsaleLib.sol, line 110)*

Registers an individual user for the crowdsale.  Only the owner can call this function.  If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address** `_registrant` Address of a buyer who is registering for the sale.

#### Returns
**bool**   

### registerUsers(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address[])   
*(EvenDistroCrowdsaleLib.sol, line 142)*

Registers a group of users for the crowdsale.  Only the owner can call this function. If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address[]** `_registrants` Addresses of buyers who are registering for the sale.

#### Returns
**bool**   

### unregisterUser(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address)   
*(EvenDistroCrowdsaleLib.sol, line 157)*

Registers an individual user for the crowdsale.  Only the owner can call this function. If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address** `_registrant` Address of a buyer who is unregistering for the sale.

#### Returns
**bool**   

### unregisterUsers(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address[])   
*(EvenDistroCrowdsaleLib.sol, line 187)*

UnRegisters a group of users for the crowdsale.  Only the owner can call this function.  If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address[]** `_registrants` Addresses of buyers who are unregistering for the sale.

#### Returns
**bool**   

### calculateAddressTokenCap(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 201)*

Internal function used for calculating the token cap per address.  It divides the total tokens by the total number of registrants to find the cap and emits an event.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### receivePurchase(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, uint256)   
*(EvenDistroCrowdsaleLib.sol, line 241)*

Accepts payment for tokens and allocates tokens available to withdraw to the buyers place in the token mapping.  Calls validPurchase to check if the purchase is legal.  If the purchase goes over the raise cap for the sale, the ether is returned and no tokens are transferred.  If the payment exceeds the address cap, the tokens are still credited to the buyer and the leftover wei is indicated in the leftoverWei mapping. It also sets the new address cap and price as each milestone is passed.  

Tokens purchased are calculated by multiplying the wei contributed by the tokensPerEth value, then moving the decimal place to reflect the token's specified granularity.  Mappings for buyer contribution, tokens purchased, and any leftover wei are updated, as well as total wei raised in the sale.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self The data storage in the calling contract.   
**uint256** `_amount` Amount being paid in terms of wei.

#### Returns
**bool** True if transaction confirmed or revoked successfully.   

### setTokens(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 329)*

Used as a last resort function in case the exchange rate is not set prior to the sale start.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### withdrawTokens(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 334)*

Allows a user to withdraw their purchased tokens whenever they want, provided they actually have purchased some.  The token's transferFrom function is called so that the token contract transfers tokens from the owners address to the buyer's address.  The owner can also call this function after the sale is over to withdraw the remaining tokens that were not sold and trigger the functionality to burn unwanted tokens.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### withdrawLeftoverWei(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 338)*

If a user had sent wei that didn't add up exactly to a whole number of tokens, the leftover wei will be recorded in the leftoverWei mapping for that user.  This function allows the user to withdraw the excess.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### withdrawOwnerEth(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 342)*

Allows the owner of the crowdsale to withdraw all the contributed ether after the sale is over.  ETH must have been contributed in the sale.  It sets the owner's balance to 0 and transfers all the ETH.

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### getSaleData(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 346)*   

Returns a 3 element array with index-0 being the timestamp, index-1 being the current token price in cents, and index-2 being the address token purchase cap.   

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   

#### Returns
**uint256[3]**    

### getTokensSold(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 354)*   

Returns the total amount of tokens sold at the time of calling.   

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   

#### Returns
**uint256**    

### crowdsaleActive(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 358)*

Returns true if the crowdsale is currently active. (If now is between the start and end time)

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   

### crowdsaleEnded(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 362)*

Returns true if the crowdsale is over. (now is after the end time)

#### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

#### Returns
**bool**   
